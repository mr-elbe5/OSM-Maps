/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class ItemListViewController: UIViewController{
    
    class Day{
        var date: Date
        var items = MapItemList()
        
        init(_ date: Date){
            self.date = date
        }
    }
    
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteSelectedButton = UIButton().asIconButton("trash.square", color: .red)
    
    var items = MapItemList()
    var days = Array<Day>()
    var sortAscending = ViewFilter.shared.defaultSortAscending
    
    var tableView = UITableView().withLayout(backgroundColor: .black)
    
    init(title: String){
        super.init(nibName: nil, bundle: nil)
        setStyleAndTitle(title: title, textColor: .white, backgroundColor: .black)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubviewFillingSafeArea(tableView, insets: .zero)
        setupNavigationItems()
        tableView.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.CELL_IDENT)
        tableView.register(AudioCell.self, forCellReuseIdentifier: AudioCell.CELL_IDENT)
        tableView.register(VideoCell.self, forCellReuseIdentifier: VideoCell.CELL_IDENT)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.CELL_IDENT)
        tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.CELL_IDENT)
    }
    
    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            self.items.deselectAll()
            self.close()
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil")), items: getTrailingBarButtos()))
        navigationItem.trailingItemGroups = groups
        
    }
    
    func getTrailingBarButtos() -> Array<UIBarButtonItem>{
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "sort".localize(), image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: UIAction(){ action in
            self.toggleSorting()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "deleteSelected".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        return items
    }
    
    func loadItems(_ items: MapItemList){
        self.items = items
        setupData()
    }
    
    func setupData(){
        days.removeAll()
        items.sortByDate(ascending: sortAscending)
        for item in items{
            let startOfDay = item.creationDate.startOfDay()
            if let day = days.first(where: { day in
                day.date == startOfDay
            }){
                day.items.append(item)
            }
            else{
                let day = Day(startOfDay)
                day.items.append(item)
                days.append(day)
            }
        }
    }
    
    func toggleSorting(){
        sortAscending = !sortAscending
        setupData()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if items.allSelected{
            items.deselectAll()
        }
        else{
            items.selectAll()
        }
        for cell in tableView.visibleCells{
            (cell as? TableViewCell)?.updateIconView()
        }
    }
    
    func deleteSelected(){
        var list = MapItemList()
        for i in 0..<items.count{
            let item = items[i]
            if item.selected{
                list.append(item)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "deleteSelected".localize(i: list.count), text: "deleteHint".localize(table: "Hints")){
            print("deleting \(list.count) items")
            for item in list{
                AppData.shared.deleteItem(withId: item.id)
                self.items.remove(obj: item)
            }
            MainViewController.shared.updateItemLayer()
            self.setupData()
            self.tableView.reloadData()
        }
    }
    
}

extension ItemListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = days[section]
        return day.items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let day = days[section]
        let header = TableSectionHeader()
        header.setupView(title: day.date.dateString())
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = days[indexPath.section]
        let item = day.items[indexPath.row]
        switch item.itemType{
        case ImageItem.itemType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.CELL_IDENT, for: indexPath) as? ImageCell, let image = item as? ImageItem{
                cell.item = image
                cell.updateCell()
                cell.delegate = self
                return cell
            }
            else{
                Log.error("no valid item/cell for image")
                return UITableViewCell()
            }
        case AudioItem.itemType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: AudioCell.CELL_IDENT, for: indexPath) as? AudioCell, let audio = item as? AudioItem{
                cell.item = audio
                cell.updateCell()
                cell.delegate = self
                return cell
            }
            else{
                Log.error("no valid item/cell for audio")
                return UITableViewCell()
            }
        case VideoItem.itemType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.CELL_IDENT, for: indexPath) as? VideoCell, let video = item as? VideoItem{
                cell.item = video
                cell.updateCell()
                cell.delegate = self
                return cell
            }
            else{
                Log.error("no valid item/cell for audio")
                return UITableViewCell()
            }
        case TrackItem.itemType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.CELL_IDENT, for: indexPath) as? TrackCell, let track = item as? TrackItem{
                cell.item = track
                cell.updateCell()
                cell.delegate = self
                return cell
            }
            else{
                Log.error("no valid item/cell for track")
                return UITableViewCell()
            }
        case NoteItem.itemType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.CELL_IDENT, for: indexPath) as? NoteCell, let note = item as? NoteItem{
                cell.item = note
                cell.updateCell()
                cell.delegate = self
                return cell
            }
            else{
                Log.error("no valid item/cell for note")
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension ItemListViewController : NoteCellDelegate{
    
    func noteChanged(item: NoteItem) {
        setupData()
        tableView.reloadData()
    }
    
}

extension ItemListViewController : ImageCellDelegate{
    
    func imageChanged(item: ImageItem) {
        setupData()
        tableView.reloadData()
        MainViewController.shared.updateItemLayer()
    }
    
}

extension ItemListViewController : AudioCellDelegate{
    
    func audioChanged(_ item: AudioItem) {
        setupData()
        tableView.reloadData()
        MainViewController.shared.updateItemLayer()
    }

}

extension ItemListViewController : VideoCellDelegate{
    
    func videoChanged(_ item: VideoItem) {
        setupData()
        tableView.reloadData()
        MainViewController.shared.updateItemLayer()
    }

}

extension ItemListViewController : TrackCellDelegate{
    
    func trackChanged(item: TrackItem) {
        setupData()
        tableView.reloadData()
    }
    
}
