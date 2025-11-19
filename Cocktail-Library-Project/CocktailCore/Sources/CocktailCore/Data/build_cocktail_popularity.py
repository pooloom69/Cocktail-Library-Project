#!/usr/bin/env python3
"""
Scrape Difford's Top 100 and match to your individual recipe JSON files.
Generates cocktail_popularity.json for your Swift app.
"""

import json
import re
import requests
from pathlib import Path
from bs4 import BeautifulSoup

# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

# Folder that contains your individual recipe JSON files
RECIPES_DIR = Path(".")

# Output file
POPULARITY_JSON = Path("cocktail_popularity.json")

DIFFORD_PAGES = [
    "https://www.diffordsguide.com/g/1127/worlds-top-100-cocktails/1-20",
    "https://www.diffordsguide.com/g/1127/worlds-top-100-cocktails/21-40",
    "https://www.diffordsguide.com/g/1127/worlds-top-100-cocktails/41-60",
    "https://www.diffordsguide.com/g/1127/worlds-top-100-cocktails/61-80",
    "https://www.diffordsguide.com/g/1127/worlds-top-100-cocktails/81-100",
]

MANUAL_OVERRIDES = {}
STOP_WORDS = {"the", "a", "an", "classic", "original", "cocktail"}


# ------------------------------------------------------------
# LOAD ALL INDIVIDUAL RECIPE FILES
# ------------------------------------------------------------

def load_all_recipes():
    recipes = []
    for file in RECIPES_DIR.glob("*.json"):
        if file.name == "cocktail_popularity.json":
            continue
        try:
            data = json.loads(file.read_text(encoding="utf-8"))
            recipes.append(data)
        except Exception as e:
            print(f"Skipping {file.name}: not a recipe file or invalid JSON.")
    print(f"Loaded {len(recipes)} recipes total.")
    return recipes


# ------------------------------------------------------------
# NAME NORMALIZATION
# ------------------------------------------------------------

def normalize(name):
    name = name.lower()
    name = name.replace("_", " ")
    name = name.replace("&", " and ")
    name = name.replace("whisky", "whiskey")

    tokens = re.findall(r"[a-z0-9]+", name)
    tokens = [t for t in tokens if t not in STOP_WORDS]

    return " ".join(tokens).strip()


def build_name_index(recipes):
    index = {}
    for r in recipes:
        rid = r["id"]
        rname = r["name"]

        index[normalize(rname)] = rid
        index[normalize(rid)] = rid
    return index


# ------------------------------------------------------------
# SCRAPE DIFFORD'S
# ------------------------------------------------------------

RANK_PATTERN = re.compile(r"(\d+)\.\s+(.+?)\s+-")

def scrape_diffords():
    results = {}
    for url in DIFFORD_PAGES:
        print(f"Scraping {url}")
        r = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
        r.raise_for_status()
        soup = BeautifulSoup(r.text, "html.parser")
        text = soup.get_text("\n", strip=True)

        for rank_str, name in RANK_PATTERN.findall(text):
            rank = int(rank_str)
            if 1 <= rank <= 100:
                results[rank] = name.strip()
    return [{"rank": r, "name": results[r]} for r in sorted(results.keys())]


# ------------------------------------------------------------
# MAIN
# ------------------------------------------------------------

def main():
    recipes = load_all_recipes()
    name_index = build_name_index(recipes)

    diffords = scrape_diffords()
    popularity = []

    local_rank = 1  # <-- your own ranking, 1..N for matched recipes

    for entry in diffords:
        external_rank = entry["rank"]   # rank from website
        ext_name = entry["name"]
        norm = normalize(ext_name)

        rid = name_index.get(norm)

        # manual override fallback
        if not rid and ext_name in MANUAL_OVERRIDES:
            override = normalize(MANUAL_OVERRIDES[ext_name])
            rid = name_index.get(override)

        if not rid:
            print(f"NO MATCH: {external_rank}. {ext_name}")
            continue

        popularity.append({
            "id": rid,
            "popularity_rank": local_rank,   # <-- your own rank
            "external_rank": external_rank,  # <-- website rank (optional)
            "name": ext_name,
            "source": "diffords_top100"
        })

        local_rank += 1  # increment your own rank for the next match

    POPULARITY_JSON.write_text(
        json.dumps(popularity, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )

    print(f"\nCreated {POPULARITY_JSON} with {len(popularity)} matched cocktails.")


if __name__ == "__main__":
    main()
