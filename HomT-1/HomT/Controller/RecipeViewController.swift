//
//  RecipeViewController.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//

import UIKit
import CoreData

class RecipeViewController: UIViewController {
      // MARK: IBOutlets
        
        @IBOutlet weak var tableView: UITableView!
        
        // MARK: Properties
        
        var recipes = Spoonacular.sharedInstance().recipes
        var dataController : DataController!
        var fetchedResultController : NSFetchedResultsController<FavRecipe>!
        // inial count for tableview cells
        var InializedCellCount = 5
        //fromFilter and refresh are bool values. they are set to true if the last view contoller was the filter view controller, but their values are updated in different places
        var fromFilter = false
        var refresh = false
        
        // MARK: UIViewController Functions
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableView.register(UINib(nibName: "MainTVRecipeCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
            self.navigationItem.title = "Recipes of the day"
            
            // get random recipes
            Spoonacular.sharedInstance().getRecipes() {(success, error) in
                if success{
                    self.recipes = Spoonacular.sharedInstance().recipes
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                }
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            dataController = DataController(modelName: "HomT")
            dataController.load()
            setUpfetchedResultController()
            
            if parent?.restorationIdentifier == "MainRecipes"{
                // if the last view was the filter result, It will need to refresh the data to present
                //new recipes not the filter result recipes
                if refresh{
                    // get new random recipes
                    Spoonacular.sharedInstance().getRecipes() {(success, error) in
                        if success{
                            self.recipes = Spoonacular.sharedInstance().recipes
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.showAlert()
                            }
                        }
                    }
                }else{
                    self.recipes = Spoonacular.sharedInstance().recipes
                    self.tableView.reloadData()
                }
            }else{
                for btn in self.navigationItem.rightBarButtonItems!{
                    btn.isEnabled = false
                }
                self.navigationItem.title = "My Favorites"
                self.tableView.reloadData()
            }
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            if parent?.restorationIdentifier == "MainRecipes"{
                if fromFilter{
                    refresh = true
                }
                fromFilter = false
            }
        }
        
        // MARK: Defined Functions
        
        fileprivate func setUpfetchedResultController() {
            let fetchRequest : NSFetchRequest<FavRecipe> = FavRecipe.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultController.delegate = self
            do{
                try fetchedResultController.performFetch()
            }catch{
                fatalError("The fetch could not be performed: \(error.localizedDescription)")
            }
        }
        
        // saves fav recipes information to coreData
        fileprivate func saveLastAddedToFavs(_ results: [[String : AnyObject]]) {
            for i in 0..<results.count{
                let favRecipe = FavRecipe(context: dataController.viewContext)
                favRecipe.id = String(describing: results[i][Spoonacular.JSONResponseKeys.id]!)
                favRecipe.title = results[i][Spoonacular.JSONResponseKeys.title] as? String
                favRecipe.minutes = Int16(results[i][Spoonacular.JSONResponseKeys.readyInMinutes] as! Int)
                favRecipe.servings = Int16(results[i][Spoonacular.JSONResponseKeys.servings] as! Int)
                favRecipe.url = results[i][Spoonacular.JSONResponseKeys.sourceUrl] as! String
                favRecipe.creationDate = Spoonacular.sharedInstance().favRecipes[favRecipe.id as! String]
                favRecipe.image = try? Data(contentsOf: URL(string: (results[i][Spoonacular.JSONResponseKeys.image] as? String)!)!)
                
                guard let ingredientsArr = results[i][Spoonacular.JSONResponseKeys.ingredients] as? [[String:AnyObject]] else { return }
                for ingredient in ingredientsArr{
                    let myIngredient = Ingredient(context: dataController.viewContext)
                    myIngredient.recipeId = favRecipe.id
                    myIngredient.original = ingredient["original"] as! String
                }
                
                guard let instructionsArr = results[i][Spoonacular.JSONResponseKeys.instructions] as? [[String:AnyObject]] else { return }
                 for instruction in instructionsArr{
                     let steps = instruction["steps"] as! [[String : AnyObject]]
                     for step in steps{
                        let myStep = Instruction(context: dataController.viewContext)
                        myStep.recipeId = favRecipe.id
                        myStep.step = step["step"] as! String
                     }
                 }
            }
            dataController.hasChanges()
            Spoonacular.sharedInstance().favRecipes.removeAll()
        }
        
        //get image data from link
        func getImage(indexPath : IndexPath) -> Data? {
            if parent?.restorationIdentifier == "MainRecipes"{
                let recipe =  self.recipes[(indexPath as NSIndexPath).row]
                guard let image = recipe.image else{ return nil}
                var url = URL(string: image)
                if !UIApplication.shared.canOpenURL(url!){
                    url = URL(string: Spoonacular.Constants.baseUri + image)!
                }
                let data = try? Data(contentsOf: url!)
                return data
            }
            else{
                let recipe =  fetchedResultController.object(at: indexPath)
                return recipe.image
            }
        }
        
        //update cell design during downloading data to activityIndicator and vice versa
        func changeCellDesign(withActivityIndicator: Bool, cell : MainTVRecipeCell){
            if withActivityIndicator{
                cell.ActivityIndicator.startAnimating()
                cell.myImageView.backgroundColor = #colorLiteral(red: 0.4078431373, green: 0.4078431373, blue: 0.2039215686, alpha: 0.66)
            }else{
                cell.ActivityIndicator.stopAnimating()
                cell.myImageView.backgroundColor = #colorLiteral(red: 1, green: 0.9278470278, blue: 0.6771306396, alpha: 0)
            }
            cell.titleLabel.isHidden = withActivityIndicator
            cell.favBtn.isHidden = withActivityIndicator
            cell.shareBtn.isHidden = withActivityIndicator
            cell.isUserInteractionEnabled = !withActivityIndicator
        }
        
        //presentActivityVC to share recipe link
        func presentActivityVC(sourceUrl: String){
            let activityVC = UIActivityViewController(activityItems: [sourceUrl as Any], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        
        //show alert on network failture
        func showAlert(){
            let alert = UIAlertController(title: "OOPS!", message: "Something went wrong, Do you prefer to reload", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                switch action.style{
                case .default:()
                @unknown default:()
                }
            }))
            self.present(alert, animated: true)
        }
        
        @IBAction func refreshButton(_ sender: Any) {
            Spoonacular.sharedInstance().getRecipes() {(success, error) in
                if success{
                    self.recipes = Spoonacular.sharedInstance().recipes
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                }
            }
        }
    }

    extension RecipeViewController : UITableViewDelegate, UITableViewDataSource{
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent?.restorationIdentifier == "MainRecipes" ? recipes.count == 0 ? InializedCellCount : recipes.count : fetchedResultController.fetchedObjects?.count ?? InializedCellCount
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell")! as! MainTVRecipeCell
            
            cell.indexPath = indexPath
            cell.delegate = self
            
            if parent?.restorationIdentifier == "MainRecipes"{
                if recipes.count != 0 {
                    changeCellDesign(withActivityIndicator: false, cell: cell)
                    
                    let recipe = self.recipes[(indexPath as NSIndexPath).row]
                    // Set the name and image
                    cell.titleLabel.text = recipe.title
                    if let imageData = getImage(indexPath: indexPath) {
                        let image = UIImage(data: imageData)
                        cell.myImageView.image = image!
                    }
                    cell.favBtn.setImage( #imageLiteral(resourceName: "emptyHeart-30x30"), for: .normal)
                    if Spoonacular.sharedInstance().favRecipes[recipe.id] != nil{
                        cell.favBtn.setImage(#imageLiteral(resourceName: "redHeart-30x30"), for: .normal)
                    }
                    for favRecipe in fetchedResultController!.fetchedObjects as! [FavRecipe]{
                        if favRecipe.id == recipe.id{
                            cell.favBtn.setImage( #imageLiteral(resourceName: "redHeart-30x30"), for: .normal)
                        }
                    }
                }else{
                    changeCellDesign(withActivityIndicator: true, cell: cell)
                }
            }else{
                changeCellDesign(withActivityIndicator: false, cell: cell)
                let recipe = fetchedResultController.object(at: indexPath)
                
                // Set the name and image
                cell.titleLabel.text = recipe.title
                cell.myImageView.image = UIImage(data: recipe.image!)
                cell.favBtn.setImage(#imageLiteral(resourceName: "redHeart-30x30"), for: .normal)
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            if recipes.count != 0 {
                guard let imageData = getImage(indexPath: indexPath) else{
                    return 0
                }
                let imageRatio = UIImage(data: imageData)!.getImageRatio()
                return tableView.frame.width / imageRatio
            }
            return 180
        }
 
         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
                let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
                    detailsVC.dataController = self.dataController
                if parent?.restorationIdentifier == "MainRecipes"{
                    let recipe = self.recipes[(indexPath as NSIndexPath).row]
                    detailsVC.recipeIndex = (indexPath as NSIndexPath).row
                    if recipe.ingredients == nil {
                        Spoonacular.sharedInstance().getRecipeInformation(recipeId: recipe.id, recipeIndex: (indexPath as NSIndexPath).row) {(success, error) in
                            if success{
                                DispatchQueue.main.async {
                                    self.navigationController?.pushViewController(detailsVC, animated: true)
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.showAlert()
                                }
                            }
                        }
                    }else{
                        self.navigationController?.pushViewController(detailsVC, animated: true)
                    }
                }else{
                    let recipe = fetchedResultController.object(at: indexPath)
                    detailsVC.recipeId = recipe.id
                    self.navigationController?.pushViewController(detailsVC, animated: true)
                }
            }
        }
