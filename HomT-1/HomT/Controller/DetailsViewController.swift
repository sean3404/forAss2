//
//  DetailsViewController.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//
import UIKit
import CoreData

class DetailsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak internal var timeLabel: UILabel!
    @IBOutlet weak internal var servingsLabel: UILabel!
    @IBOutlet weak internal var favBtn: UIButton!
    @IBOutlet weak var ingredientsTV: UITableView!
    @IBOutlet weak var ingredientsHC: NSLayoutConstraint!
    @IBOutlet weak var instruncionsTV: UITableView!
    @IBOutlet weak var instruncionsHC: NSLayoutConstraint!
    
    var recipeIndex : Int?
    var recipe : Recipe?
    
    var recipeId : String?
    var url : String?
    var dataController : DataController!
    var recipesFetchedresultController : NSFetchedResultsController<FavRecipe>!
    var IngredientsFetchedresultController : NSFetchedResultsController<Ingredient>!
    var InstructionsFetchedresultController : NSFetchedResultsController<Instruction>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if recipeIndex != nil{
            recipe = Spoonacular.sharedInstance().recipes[recipeIndex!]
            recipeId = recipe?.id
            setUpFetchedResultController()
            self.titleLabel.text = recipe!.title
            self.imageView.image = UIImage(data: getImage(imageURL: (recipe?.image!)!)!)
            self.timeLabel.text = "\(recipe!.readyInMinutes!)" + " Mins"
            self.servingsLabel.text =  " serves " + "\(recipe!.servings!)"
            ingredientsHC.constant = CGFloat(recipe?.ingredients?.count ?? 0) * ingredientsTV.rowHeight
            instruncionsHC.constant = CGFloat(recipe?.instructions?.count ?? 0) * instruncionsTV.rowHeight
            if recipesFetchedresultController.fetchedObjects?.first?.id != nil{
                self.favBtn.setImage(#imageLiteral(resourceName: "redHeart-30x30"), for: .normal)
            }
            url = recipe!.recipeURL!
        }else{
            setUpFetchedResultController()
            let favRecipe = recipesFetchedresultController.fetchedObjects?.first
            self.titleLabel.text = favRecipe!.title
            self.imageView.image = UIImage(data: ((favRecipe?.image!)!))
            self.timeLabel.text = "\(favRecipe!.minutes)" + " Mins"
            self.servingsLabel.text =  " serves " + "\(favRecipe!.servings)"
            self.favBtn.setImage(#imageLiteral(resourceName: "redHeart-30x30"), for: .normal)
            ingredientsHC.constant = CGFloat(IngredientsFetchedresultController.fetchedObjects?.count ?? 0) * ingredientsTV.rowHeight
            instruncionsHC.constant = CGFloat(InstructionsFetchedresultController.fetchedObjects?.count ?? 0) * instruncionsTV.rowHeight
            url = favRecipe?.url
        }
        
    }
    
    fileprivate func setUpFetchedResultController() {
        let recipeFetchRequest : NSFetchRequest<FavRecipe> = FavRecipe.fetchRequest()
        let recipeSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        recipeFetchRequest.sortDescriptors = [recipeSortDescriptor]
        recipeFetchRequest.predicate = NSPredicate(format: "id == %@", recipeId!)
        recipesFetchedresultController = NSFetchedResultsController(fetchRequest: recipeFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        recipesFetchedresultController.delegate = self
        
        let IngredientFetchRequest : NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        let IngredientSortDescriptor = NSSortDescriptor(key: "recipeId", ascending: false)
        IngredientFetchRequest.sortDescriptors = [IngredientSortDescriptor]
        IngredientFetchRequest.predicate = NSPredicate(format: "recipeId == %@", recipeId!)
        IngredientsFetchedresultController = NSFetchedResultsController(fetchRequest: IngredientFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        IngredientsFetchedresultController.delegate = self
        
        let InstructionFetchRequest : NSFetchRequest<Instruction> = Instruction.fetchRequest()
        let InstructionSortDescriptor = NSSortDescriptor(key: "recipeId", ascending: false)
        InstructionFetchRequest.sortDescriptors = [InstructionSortDescriptor]
        InstructionFetchRequest.predicate = NSPredicate(format: "recipeId == %@", recipeId!)
        InstructionsFetchedresultController = NSFetchedResultsController(fetchRequest: InstructionFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        InstructionsFetchedresultController.delegate = self
        
        do{
            try recipesFetchedresultController.performFetch()
            try IngredientsFetchedresultController.performFetch()
            try InstructionsFetchedresultController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func getImage(imageURL : String) -> Data? {
        var url = URL(string: imageURL)
        if !UIApplication.shared.canOpenURL(url!){
            url = URL(string: Spoonacular.Constants.baseUri + imageURL)!
        }
        let data = try? Data(contentsOf: url!)
        return data
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "OOPS!", message: "Something went wrong, Do you prefer to reload", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.viewWillAppear(true)
            @unknown default:()
            }
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func shareBtnPressed(_ sender: UIButton) {
        if recipeIndex != nil{
            Spoonacular.sharedInstance().getRecipeLink(recipeId: recipe!.id)
            {(SourceUrl, error) in
                if error == nil{
                    let activityVC = UIActivityViewController(activityItems: [SourceUrl as Any], applicationActivities: nil)
                    DispatchQueue.main.async {
                        self.present(activityVC, animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                }
            }
        }else{
            let favRecipe = recipesFetchedresultController.fetchedObjects?.first
            let activityVC = UIActivityViewController(activityItems: [favRecipe?.url as Any], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
        
    @IBAction func favBtnPressed(_ sender: UIButton) {
        let myRecipeId = recipeIndex != nil ? recipe!.id : recipeId!
        if favBtn.currentImage == #imageLiteral(resourceName: "emptyHeart-30x30"){
            favBtn.setImage(#imageLiteral(resourceName: "redHeart-30x30"), for: .normal)
            saveRecipeToCoreData(recipeId: myRecipeId!)
        }else{
            favBtn.setImage(#imageLiteral(resourceName: "emptyHeart-30x30"), for: .normal)
            if let recipeToDelete = recipesFetchedresultController.fetchedObjects?.first as? FavRecipe {
                dataController.viewContext.delete(recipeToDelete)
                dataController.hasChanges()
            }
        }
    }
    
    func saveRecipeToCoreData(recipeId : String){
        let favRecipe = FavRecipe(context: self.dataController.viewContext)
        favRecipe.id = recipeId
        favRecipe.title = self.titleLabel.text
        favRecipe.minutes = Int16((self.timeLabel.text?.replacingOccurrences(of: " Mins", with: ""))!)!
        favRecipe.servings = Int16(self.servingsLabel.text!.replacingOccurrences(of: " serves ", with: ""))!
        favRecipe.url = self.url
        favRecipe.creationDate = Date()
        favRecipe.image = self.imageView.image?.pngData()
        
        for cell in ingredientsTV.visibleCells{
            let myIngredient = Ingredient(context: self.dataController.viewContext)
            myIngredient.recipeId = recipeId
            myIngredient.original = cell.textLabel?.text
        }
        for cell in instruncionsTV.visibleCells {
            let Mynstruction = Instruction(context: self.dataController.viewContext)
            Mynstruction.recipeId = recipeId
            Mynstruction.step = cell.textLabel?.text
        }
        dataController.hasChanges()
    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recipeIndex != nil{
            if tableView == ingredientsTV{
                return recipe?.ingredients?.count ?? 0
            }else{
                return recipe?.instructions?.count ?? 0
            }
        }else{
            if tableView == ingredientsTV{
                return IngredientsFetchedresultController.fetchedObjects?.count ?? 0
            }else{
                return InstructionsFetchedresultController.fetchedObjects?.count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if tableView == ingredientsTV{
            cell = tableView.dequeueReusableCell(withIdentifier: "DetailsIngredientsTVCell")!
            cell.textLabel?.text = recipeIndex != nil ? (recipe?.ingredients![indexPath.row]) : IngredientsFetchedresultController.object(at: indexPath).original
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "InstructionsTVCell")!
            cell.textLabel?.text = "\(indexPath.row + 1)) \((recipeIndex != nil ? (recipe?.instructions![indexPath.row]) : InstructionsFetchedresultController.object(at: indexPath).step)! )"
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font.withSize(12)

        return cell
    }
}

