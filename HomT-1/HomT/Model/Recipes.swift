//
//  Recipes.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//

struct Recipe{
    
    var id : String!
    var title : String?
    var image : String?
    var readyInMinutes : Int?
    var servings: Int?
    var recipeURL : String?
    var ingredients : [String]?
    var instructions : [String]?
    
    init(dictionary: [String:AnyObject]) {
        id = String(describing: dictionary[Spoonacular.JSONResponseKeys.id]!)
        title = dictionary[Spoonacular.JSONResponseKeys.title] as? String
        image = dictionary[Spoonacular.JSONResponseKeys.image] as? String
       }
    
    static func getRecipesFromResults(_ results: [[String:AnyObject]]) -> [Recipe] {
        
        var recipes = [Recipe]()
        
        for result in results {
            recipes.append(Recipe (dictionary: result))
        }
        
        return recipes
    }
    
    mutating func setRemainPropertires(_ dictionary: [String:AnyObject]){
        readyInMinutes = dictionary[Spoonacular.JSONResponseKeys.readyInMinutes] as! Int
        servings = dictionary[Spoonacular.JSONResponseKeys.servings] as! Int
        recipeURL = dictionary[Spoonacular.JSONResponseKeys.sourceUrl] as! String
        image = dictionary[Spoonacular.JSONResponseKeys.image] as! String
        
        guard let ingredientsArr = dictionary[Spoonacular.JSONResponseKeys.ingredients] as? [[String:AnyObject]] else { return }
        ingredients = [String]()
        for ingredient in ingredientsArr{
            ingredients?.append(ingredient["original"] as! String)
        }
        
        guard let instructionsArr = dictionary[Spoonacular.JSONResponseKeys.instructions] as? [[String:AnyObject]] else { return }
        
        instructions = [String]()
        for instruction in instructionsArr{
            let steps = instruction["steps"] as! [[String : AnyObject]]
            for step in steps{
                instructions?.append(step["step"] as! String)
            }
        }
    }
}

