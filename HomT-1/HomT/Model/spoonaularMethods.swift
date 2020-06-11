//
//  spoonaularMethods.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//

extension Spoonacular{
    
    
    func getRecipes(completionHandlerForRecipes: @escaping (_ success : Bool, _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey, ParameterKeys.number:ParameterValues.number] as! [String : AnyObject]
        taskForGETMethod(Constants.subdomain, method: URLExtentions.searchRecipes, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForRecipes(false, error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let mainDictionary = results as! [String: AnyObject]
                let resultDictionry = mainDictionary["recipes"] as? [[String: AnyObject]]
                self.recipes = Recipe.getRecipesFromResults(resultDictionry!)
                completionHandlerForRecipes(true, nil)
            }
        }
        
    }
    
    func getRecipeLink(recipeId : String, completionHandlerForRecipes: @escaping (_ SourceUrl : String, _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey] as! [String : AnyObject]
        
        let extention = URLExtentions.recipes + recipeId + "/information"
        taskForGETMethod(Constants.subdomain, method: extention, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForRecipes("", error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let mainDictionary = results as! [String: AnyObject]
                let SourceUrl = mainDictionary["sourceUrl"] as? String
                completionHandlerForRecipes(SourceUrl!, nil)
            }
        }
        
    }
    
    func autoCompleteIngredients(ingredient : String, completionHandlerForRecipes: @escaping (_ names : [String], _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey, ParameterKeys.query:ingredient, ParameterKeys.number:ParameterValues.number] as! [String : AnyObject]
        
        let extention = URLExtentions.autoCompleteIngredients
        taskForGETMethod(Constants.subdomain, method: extention, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForRecipes([String](), error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let resultsArr = results as! [[String: String]]
                var namesArr = [String]()
                for result in resultsArr{
                    namesArr.append(result["name"]!)
                }
                completionHandlerForRecipes(namesArr, nil)
            }
        }
        
    }
    
    func autoCompleteRecipes(recipes : String, completionHandlerForRecipes: @escaping (_ titles : [String], _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey, ParameterKeys.query:recipes, ParameterKeys.number:ParameterValues.number] as! [String : AnyObject]
        
        let extention = URLExtentions.autoCompleteRecipes
        taskForGETMethod(Constants.subdomain, method: extention, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForRecipes([String](), error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let resultsArr = results as! [[String: AnyObject]]
                var titlesArr = [String]()
                for result in resultsArr{
                    titlesArr.append(result["title"]! as! String)
                }
                completionHandlerForRecipes(titlesArr, nil)
            }
        }
        
    }
    
    func recipesComplexSearch(recipes : String, ingredients : String, type : String, cuisine : String, diet : String, maxReadyTime : Int, completionHandlerForComplexSearch: @escaping (_ success : Bool, _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey, ParameterKeys.number:ParameterValues.number, ParameterKeys.query:recipes, ParameterKeys.ingredients:ingredients, ParameterKeys.type:type, ParameterKeys.cuisine:cuisine, ParameterKeys.diet:diet, ParameterKeys.maxReadyTime:maxReadyTime] as! [String : AnyObject]
        
        let extention = URLExtentions.recipesComplexSearch
        taskForGETMethod(Constants.subdomain, method: extention, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForComplexSearch(false, error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let mainDictionary = results as! [String: AnyObject]
                let resultDictionry = mainDictionary["results"] as? [[String: AnyObject]]
                self.recipes = Recipe.getRecipesFromResults(resultDictionry!)
                completionHandlerForComplexSearch(true, nil)
            }
        }
        
    }
    
    func getRecipeInformation(recipeId : String, recipeIndex:Int, completionHandlerForRecipeInformation: @escaping (_ success : Bool, _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey] as! [String : AnyObject]
        let extention = URLExtentions.recipes + recipeId + "/information"
        taskForGETMethod(Constants.subdomain, method: extention, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForRecipeInformation(false, error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let mainDictionary = results as! [String: AnyObject]
                self.recipes[recipeIndex].setRemainPropertires(mainDictionary)
                completionHandlerForRecipeInformation(true, nil)
            }
        }
    }
    
    func getRecipeInformationBulk(Ids : String, completionHandlerForRecipeInformationBulk: @escaping (_ RecipesArr : [[String: AnyObject]], _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey, ParameterKeys.ids:Ids] as! [String : AnyObject]
        let extention = URLExtentions.recipesInformationBulk
        taskForGETMethod(Constants.subdomain, method: extention, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForRecipeInformationBulk([[String: AnyObject]](), error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let RecipesArr = results as! [[String: AnyObject]]
                completionHandlerForRecipeInformationBulk(RecipesArr, nil)
            }
        }
    }
    
    func getRecipeInformation(recipeId : String, completionHandlerForRecipeInformationBulk: @escaping (_ recipe : [String: AnyObject], _ errorString: String?) -> Void){
        let parameters = [ParameterKeys.apiKey:ParameterValues.apiKey] as! [String : AnyObject]
        let extention = URLExtentions.recipes + recipeId + "/information"
        taskForGETMethod(Constants.subdomain, method: extention, parameters: parameters){(results, error) in
            
            if let error = error {
                completionHandlerForRecipeInformationBulk([String: AnyObject](), error.userInfo["NSLocalizedDescription"] as! String)
            } else {
                let recipe = results as! [String: AnyObject]
                completionHandlerForRecipeInformationBulk(recipe, nil)
            }
        }
    }
}

