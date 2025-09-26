# StoreManager.gd (Attached to the Store UI Root)
extends Control

# Assuming you have a list of all your StoreItem resources loaded here
var all_items: Array[StoreItem] = [] 
# You'd load these either by hand or programmatically from a folder

func _ready():
    # Example: Manually load items for testing
    # all_items.append(load("res://Items/DoubleJump.tres"))
    # all_items.append(load("res://Items/DashAbility.tres"))
    pass

func attempt_purchase(item: StoreItem) -> bool:
    if GameData.coins >= item.cost:
        if item.id in GameData.owned_abilities:
            print("Already owned!")
            # Add logic for handling upgrades if applicable
            return false
        
        # 1. Deduct cost
        GameData.coins -= item.cost
        
        # 2. Grant the item/ability
        GameData.owned_abilities.append(item.id)
        
        # 3. Update the UI to show the item is now owned/sold out
        update_store_display()
        
        print("Purchased %s for %d coins." % [item.item_name, item.cost])
        return true
    else:
        print("Not enough coins to buy %s (Need %d, Have %d)" % [item.item_name, item.cost, GameData.coins])
        return false

func update_store_display():
    # Loop through all_items and refresh the UI to reflect new ownership/coin count
    pass # This is where you connect the data to your item buttons/panels