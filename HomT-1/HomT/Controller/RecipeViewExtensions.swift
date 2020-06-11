//
//  RecipeViewExtensions.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//
import UIKit
import CoreData

extension RecipeViewController: CellActionDelegate {
    
    func shareARecipe(indexPath: IndexPath) {
        var sourceUrl : String?
        if parent?.restorationIdentifier == "MainRecipes"{
            let recipe = self.recipes[(indexPath as NSIndexPath).row]
            if recipe.recipeURL == nil{
                Spoonacular.sharedInstance().getRecipeLink(recipeId: recipe.id)
                {(SourceUrl, error) in
                    if error == nil{
                        DispatchQueue.main.async {
                            self.presentActivityVC(sourceUrl: SourceUrl)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.showAlert()
                        }
                    }
                }
            }else{
                presentActivityVC(sourceUrl: recipe.recipeURL!)
            }
        }else{
            let recipe = fetchedResultController.object(at: indexPath)
            presentActivityVC(sourceUrl: recipe.url!)
        }
    }
    
    func addToFav(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MainTVRecipeCell
        let recipeId = parent?.restorationIdentifier == "MainRecipes" ? self.recipes[(indexPath as! NSIndexPath).row].id : fetchedResultController.object(at: indexPath).id
        
        if cell.favBtn.currentImage == #imageLiteral(resourceName: "emptyHeart-30x30"){
            cell.favBtn.setImage(#imageLiteral(resourceName: "redHeart-30x30"), for: .normal)
            Spoonacular.sharedInstance().getRecipeInformation(recipeId: recipeId!)
            {(recipe, error) in
                if error == nil{
                    self.saveRecipe(recipe: recipe)
                }else{
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                }
            }
        }else{
            cell.favBtn.setImage(#imageLiteral(resourceName: "emptyHeart-30x30"), for: .normal)
            var recipeToDelete : FavRecipe?
            if parent?.restorationIdentifier == "MainRecipes"{
                for recipe in fetchedResultController.fetchedObjects as! [FavRecipe]{
                    if recipe.id == recipeId{
                        recipeToDelete = recipe
                    }
                }
            }else{
                recipeToDelete = fetchedResultController.object(at: indexPath)
            }
            dataController.viewContext.delete(recipeToDelete!)
            dataController.hasChanges()
        }
      }
    
    func saveRecipe(recipe:[String:AnyObject]){
        let favRecipe = FavRecipe(context: self.dataController.viewContext)
        favRecipe.id = String(describing: recipe[Spoonacular.JSONResponseKeys.id]!)
        favRecipe.title = recipe[Spoonacular.JSONResponseKeys.title] as? String
        favRecipe.minutes = Int16(recipe[Spoonacular.JSONResponseKeys.readyInMinutes] as! Int)
        favRecipe.servings = Int16(recipe[Spoonacular.JSONResponseKeys.servings] as! Int)
        favRecipe.url = recipe[Spoonacular.JSONResponseKeys.sourceUrl] as? String
        favRecipe.creationDate = Date()
        favRecipe.image = try? Data(contentsOf: URL(string: (recipe[Spoonacular.JSONResponseKeys.image] as? String)!)!)
        
        guard let ingredientsArr = recipe[Spoonacular.JSONResponseKeys.ingredients] as? [[String:AnyObject]] else { return }
        for ingredient in ingredientsArr{
            let myIngredient = Ingredient(context: self.dataController.viewContext)
            myIngredient.recipeId = favRecipe.id
            myIngredient.original = ingredient["original"] as? String
        }
        
        guard let instructionsArr = recipe[Spoonacular.JSONResponseKeys.instructions] as? [[String:AnyObject]] else { return }
        for instruction in instructionsArr{
            let steps = instruction["steps"] as! [[String : AnyObject]]
            for step in steps{
                let myStep = Instruction(context: self.dataController.viewContext)
                myStep.recipeId = favRecipe.id
                myStep.step = step["step"] as? String
            }
        }
        dataController.hasChanges()
    }
}

extension RecipeViewController: NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if parent?.restorationIdentifier == "FavRecipes"{
                tableView.deleteRows(at: [indexPath!], with: .left)
            }
        default:
            break
        }
    }
}

extension UIImage {
    func getImageRatio() -> CGFloat {
        let imageRatio = CGFloat(self.size.width / self.size.height)
        return imageRatio
    }
}
