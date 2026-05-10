# Card Data Structure Schema

## Overview

This document defines the JSON schema for card data in Balatro.

## Card Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Card",
  "type": "object",
  "required": ["id", "name", "suit", "rank"],
  "properties": {
    "id": {
      "type": "string",
      "description": "Unique identifier for the card"
    },
    "name": {
      "type": "string",
      "description": "Display name of the card"
    },
    "suit": {
      "type": "string",
      "enum": ["hearts", "diamonds", "clubs", "spades"],
      "description": "Card suit"
    },
    "rank": {
      "type": "integer",
      "minimum": 1,
      "maximum": 13,
      "description": "Card rank (1=Ace, 2-10, 11=Jack, 12=Queen, 13=King)"
    },
    "cost": {
      "type": "integer",
      "minimum": 0,
      "default": 0,
      "description": "Energy cost to play this card"
    },
    "tags": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "default": [],
      "description": "Tags for card categorization"
    },
    "effects": {
      "type": "array",
      "items": {
        "$ref": "#/definitions/Effect"
      },
      "default": [],
      "description": "List of effects this card applies"
    }
  }
}
```

## Joker Card Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "JokerCard",
  "type": "object",
  "required": ["id", "name", "rarity"],
  "properties": {
    "id": {
      "type": "string",
      "description": "Unique identifier for the joker"
    },
    "name": {
      "type": "string",
      "description": "Display name of the joker"
    },
    "description": {
      "type": "string",
      "description": "Effect description shown to player"
    },
    "rarity": {
      "type": "string",
      "enum": ["common", "uncommon", "rare", "legendary"],
      "description": "Rarity tier"
    },
    "cost": {
      "type": "integer",
      "minimum": 0,
      "default": 4,
      "description": "Shop price"
    },
    "slots_required": {
      "type": "integer",
      "minimum": 1,
      "default": 1,
      "description": "Number of slots consumed"
    },
    "effects": {
      "type": "array",
      "items": {
        "$ref": "#/definitions/Effect"
      },
      "description": "Persistent effects applied while equipped"
    }
  }
}
```

## Effect Schema

```json
{
  "definitions": {
    "Effect": {
      "type": "object",
      "required": ["type"],
      "properties": {
        "type": {
          "type": "string",
          "enum": [
            "score_multiply",
            "score_add",
            "multiply_chips",
            "add_chips",
            "modify_hand",
            "modify_card",
            "economy",
            "utility"
          ],
          "description": "Effect type"
        },
        "value": {
          "type": "number",
          "description": "Effect magnitude"
        },
        "condition": {
          "type": "object",
          "description": "Optional trigger condition",
          "properties": {
            "hand_type": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "suit_required": {
              "type": "string"
            },
            "card_count": {
              "type": "integer"
            }
          }
        }
      }
    }
  }
}
```

## Hand Types

| Hand Type | Description | Base Score |
|-----------|-------------|------------|
| royal_flush | A,10,J,Q,K of same suit | 100 |
| straight_flush | 5 consecutive same suit | 75 |
| four_of_a_kind | 4 same rank | 60 |
| full_house | 3 + 2 of same rank | 40 |
| flush | 5 same suit | 35 |
| straight | 5 consecutive | 30 |
| three_of_a_kind | 3 same rank | 20 |
| two_pair | 2 + 2 different ranks | 15 |
| one_pair | 2 same rank | 10 |
| high_card | Highest single card | 5 |

## Example Card Data

```json
{
  "id": "hearts_ace",
  "name": "Ace of Hearts",
  "suit": "hearts",
  "rank": 1,
  "cost": 0,
  "tags": ["face_card", "high_value"]
}
```

## Example Joker Data

```json
{
  "id": "joker_fortune",
  "name": "Fortune Teller",
  "description": "+2 Mult for each Tarot card this round",
  "rarity": "common",
  "cost": 5,
  "slots_required": 1,
  "effects": [
    {
      "type": "score_multiply",
      "value": 2,
      "condition": {
        "utility_card": "tarot"
      }
    }
  ]
}
```
