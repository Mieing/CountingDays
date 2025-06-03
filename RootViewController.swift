import UIKit

class RootViewController: UITableViewController {
	private var events: [DateEvent] = []
	private let defaults = UserDefaults.standard
	private let eventsKey = "savedEvents"
	private var selectedIndexPaths: Set<IndexPath> = []
	private var isInSelectionMode = false
	
	// 工具栏按钮
	private lazy var selectAllButton: UIBarButtonItem = {
		let button = UIBarButtonItem(
			image: UIImage(systemName: "checkmark.circle"),
			style: .plain,
			target: self,
			action: #selector(selectAllTapped)
		)
		return button
	}()
	
	private lazy var deleteButton: UIBarButtonItem = {
		let button = UIBarButtonItem(
			image: UIImage(systemName: "trash"),
			style: .plain,
			target: self,
			action: #selector(deleteSelectedTapped)
		)
		button.tintColor = .systemRed
		return button
	}()
	
	private lazy var cancelButton: UIBarButtonItem = {
		let button = UIBarButtonItem(
			title: "取消",
			style: .plain,
			target: self,
			action: #selector(cancelSelection)
		)
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		loadEvents()
		setupGestureRecognizers()
	}
	
	deinit {
		// 清理通知和手势识别器
		NotificationCenter.default.removeObserver(self)
		if let recognizers = tableView.gestureRecognizers {
			for recognizer in recognizers {
				if recognizer is UILongPressGestureRecognizer {
					tableView.removeGestureRecognizer(recognizer)
				}
			}
		}
	}
	
	private func setupUI() {
		title = "倒数日"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		tableView.register(DateEventCell.self, forCellReuseIdentifier: DateEventCell.reuseIdentifier)
		tableView.separatorStyle = .none
		tableView.backgroundColor = .systemGroupedBackground
		
		// 启用拖拽重排
		tableView.dragInteractionEnabled = true
		tableView.dragDelegate = self
		tableView.dropDelegate = self
		
		// Initial setup of navigation items
		let addButton = UIBarButtonItem(
			image: UIImage(systemName: "plus.circle.fill"),
			style: .done,
			target: self,
			action: #selector(addButtonTapped)
		)
		addButton.tintColor = .systemBlue
		
		let moreButton = UIBarButtonItem(
			image: UIImage(systemName: "ellipsis.circle"),
			style: .plain,
			target: self,
			action: #selector(showMoreOptions)
		)
		
		navigationItem.rightBarButtonItems = [addButton, moreButton]
	}
	
	private func setupGestureRecognizers() {
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
		longPress.minimumPressDuration = 0.5
		tableView.addGestureRecognizer(longPress)
	}
	
	private func updateToolbarItems() {
		if isInSelectionMode {
			navigationItem.rightBarButtonItems = [cancelButton]
			toolbarItems = [
				selectAllButton,
				UIBarButtonItem(systemItem: .flexibleSpace),
				deleteButton
			]
			navigationController?.setToolbarHidden(false, animated: true)
		} else {
			let addButton = UIBarButtonItem(
				image: UIImage(systemName: "plus.circle.fill"),
				style: .done,
				target: self,
				action: #selector(addButtonTapped)
			)
			addButton.tintColor = .systemBlue
			
			let moreButton = UIBarButtonItem(
				image: UIImage(systemName: "ellipsis.circle"),
				style: .plain,
				target: self,
				action: #selector(showMoreOptions)
			)
			
			navigationItem.rightBarButtonItems = [addButton, moreButton]
			navigationController?.setToolbarHidden(true, animated: true)
			selectedIndexPaths.removeAll()
			tableView.reloadData()
		}
	}
	
	@objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
		if gesture.state == .began {
			let point = gesture.location(in: tableView)
			if let indexPath = tableView.indexPathForRow(at: point) {
				enterSelectionMode()
				selectItem(at: indexPath)
			}
		}
	}
	
	private func enterSelectionMode() {
		if !isInSelectionMode {
			isInSelectionMode = true
			updateToolbarItems()
			// 添加轻微的震动反馈
			let generator = UIImpactFeedbackGenerator(style: .medium)
			generator.impactOccurred()
		}
	}
	
	private func selectItem(at indexPath: IndexPath) {
		if selectedIndexPaths.contains(indexPath) {
			selectedIndexPaths.remove(indexPath)
		} else {
			selectedIndexPaths.insert(indexPath)
		}
		
		if let cell = tableView.cellForRow(at: indexPath) as? DateEventCell {
			UIView.animate(withDuration: 0.2) {
				cell.setSelected(self.selectedIndexPaths.contains(indexPath))
			}
		}
		
		updateSelectionUI()
	}
	
	private func updateSelectionUI() {
		selectAllButton.image = selectedIndexPaths.count == events.count ?
			UIImage(systemName: "checkmark.circle.fill") :
			UIImage(systemName: "checkmark.circle")
		
		deleteButton.isEnabled = !selectedIndexPaths.isEmpty
	}
	
	@objc private func selectAllTapped() {
		if selectedIndexPaths.count == events.count {
			selectedIndexPaths.removeAll()
		} else {
			selectedIndexPaths = Set(tableView.indexPathsForVisibleRows ?? [])
		}
		
		tableView.visibleCells.forEach { [weak self] cell in
			guard let self = self else { return }
			if let dateCell = cell as? DateEventCell,
			   let indexPath = self.tableView.indexPath(for: cell) {
				UIView.animate(withDuration: 0.2) {
					dateCell.setSelected(self.selectedIndexPaths.contains(indexPath))
				}
			}
		}
		
		updateSelectionUI()
	}
	
	@objc private func deleteSelectedTapped() {
		let sortedIndexPaths = selectedIndexPaths.sorted().reversed()
		
		// 创建删除动画
		UIView.animate(withDuration: 0.3, animations: {
			sortedIndexPaths.forEach { indexPath in
				if let cell = self.tableView.cellForRow(at: indexPath) {
					cell.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
					cell.alpha = 0
				}
			}
		}) { _ in
			// 实际删除数据
			sortedIndexPaths.forEach { indexPath in
				self.events.remove(at: indexPath.row)
			}
			self.saveEvents()
			
			// 更新UI
			self.tableView.deleteRows(at: Array(self.selectedIndexPaths), with: .fade)
			self.selectedIndexPaths.removeAll()
			self.isInSelectionMode = false
			self.updateToolbarItems()
		}
	}
	
	@objc private func cancelSelection() {
		isInSelectionMode = false
		selectedIndexPaths.removeAll()
		updateToolbarItems()
		tableView.reloadData()
	}
	
	@objc private func showMoreOptions() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: "多选", style: .default) { [weak self] _ in
			self?.enterSelectionMode()
		})
		
		alert.addAction(UIAlertAction(title: "排序", style: .default) { [weak self] _ in
			self?.showSortOptions()
		})
		
		alert.addAction(UIAlertAction(title: "取消", style: .cancel))
		
		present(alert, animated: true)
	}
	
	private func showSortOptions() {
		let alert = UIAlertController(title: "排序方式", message: nil, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: "按日期排序", style: .default) { [weak self] _ in
			self?.sortEvents(by: .date)
		})
		
		alert.addAction(UIAlertAction(title: "按标题排序", style: .default) { [weak self] _ in
			self?.sortEvents(by: .title)
		})
		
		alert.addAction(UIAlertAction(title: "按类型排序", style: .default) { [weak self] _ in
			self?.sortEvents(by: .type)
		})
		
		alert.addAction(UIAlertAction(title: "取消", style: .cancel))
		
		present(alert, animated: true)
	}
	
	private enum SortOption {
		case date, title, type
	}
	
	private func sortEvents(by option: SortOption) {
		switch option {
		case .date:
			events.sort { $0.date < $1.date }
		case .title:
			events.sort { $0.title < $1.title }
		case .type:
			events.sort { event1, event2 in
				switch (event1.type, event2.type) {
				case (.countdown, .countup): return true
				case (.countup, .countdown): return false
				case (.countdown, .countdown): return event1.daysRemaining < event2.daysRemaining
				case (.countup, .countup): return event1.daysElapsed > event2.daysElapsed
				}
			}
		}
		
		saveEvents()
		UIView.transition(with: tableView,
						 duration: 0.3,
						 options: .transitionCrossDissolve,
						 animations: { self.tableView.reloadData() })
	}
	
	private func loadEvents() {
		if let data = defaults.data(forKey: eventsKey) {
			do {
				events = try JSONDecoder().decode([DateEvent].self, from: data)
				events.sort { event1, event2 in
					switch (event1.type, event2.type) {
					case (.countdown, .countup): return true
					case (.countup, .countdown): return false
					case (.countdown, .countdown): return event1.daysRemaining < event2.daysRemaining
					case (.countup, .countup): return event1.daysElapsed > event2.daysElapsed
					}
				}
			} catch {
				print("Error loading events: \(error)")
				events = []
			}
		}
	}
	
	private func saveEvents() {
		do {
			let data = try JSONEncoder().encode(events)
			defaults.set(data, forKey: eventsKey)
		} catch {
			print("Error saving events: \(error)")
		}
	}
	
	@objc private func addButtonTapped() {
		let alert = UIAlertController(title: "新建倒数日", message: nil, preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "标题"
			textField.clearButtonMode = .whileEditing
		}
		
		alert.addTextField { textField in
			textField.placeholder = "日期"
			let datePicker = UIDatePicker()
			datePicker.datePickerMode = .date
			datePicker.preferredDatePickerStyle = .wheels
			datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
			textField.inputView = datePicker
		}
		
		let colors = ["#FF9999", "#99FF99", "#9999FF", "#FFFF99", "#FF99FF", "#99FFFF"]
		let randomColor = colors.randomElement() ?? "#FF9999"
		
		let cancelAction = UIAlertAction(title: "取消", style: .cancel)
		let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
			guard let title = alert.textFields?[0].text, !title.isEmpty,
				  let dateString = alert.textFields?[1].text, !dateString.isEmpty,
				  let date = self?.dateFormatter.date(from: dateString) else {
				self?.showError(message: "请输入有效的标题和日期")
				return
			}
			
			let event = DateEvent(
				title: title,
				date: date,
				type: date > Date() ? .countdown : .countup,
				color: randomColor
			)
			
			self?.events.append(event)
			self?.events.sort { event1, event2 in
				switch (event1.type, event2.type) {
				case (.countdown, .countup): return true
				case (.countup, .countdown): return false
				case (.countdown, .countdown): return event1.daysRemaining < event2.daysRemaining
				case (.countup, .countup): return event1.daysElapsed > event2.daysElapsed
				}
			}
			
			self?.saveEvents()
			UIView.transition(with: self?.tableView ?? UITableView(),
							duration: 0.3,
							options: .transitionCrossDissolve,
							animations: { self?.tableView.reloadData() })
		}
		
		alert.addAction(cancelAction)
		alert.addAction(addAction)
		
		if let dateField = alert.textFields?[1] {
			dateField.text = dateFormatter.string(from: Date())
		}
		
		present(alert, animated: true)
	}
	
	private func showError(message: String) {
		let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "确定", style: .default))
		present(alert, animated: true)
	}
	
	@objc private func dateChanged(_ sender: UIDatePicker) {
		if let dateField = (presentedViewController as? UIAlertController)?.textFields?[1] {
			dateField.text = dateFormatter.string(from: sender.date)
		}
	}
	
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy年MM月dd日"
		formatter.dateStyle = .medium
		formatter.locale = Locale(identifier: "zh_CN")
		return formatter
	}()
	
	// MARK: - Table View Data Source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return events.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DateEventCell.reuseIdentifier, for: indexPath) as! DateEventCell
		let event = events[indexPath.row]
		cell.configure(with: event)
		cell.setSelected(selectedIndexPaths.contains(indexPath))
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if isInSelectionMode {
			selectItem(at: indexPath)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			events.remove(at: indexPath.row)
			saveEvents()
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
			guard let self = self else { return }
			
			guard let cell = tableView.cellForRow(at: indexPath) as? DateEventCell else {
				completion(true)
				return
			}
			
			UIView.animate(withDuration: 0.3, animations: {
				cell.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
				cell.alpha = 0
			}) { _ in
				self.events.remove(at: indexPath.row)
				self.saveEvents()
				tableView.deleteRows(at: [indexPath], with: .fade)
				completion(true)
			}
		}
		
		// 使用更柔和的删除按钮样式，同时确保在浅色模式下可见
		deleteAction.image = UIImage(systemName: "trash.circle.fill")?.withConfiguration(
			UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
		)
		deleteAction.backgroundColor = .systemRed.withAlphaComponent(0.8)
		
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true
		
		// 添加触觉反馈
		let generator = UIImpactFeedbackGenerator(style: .medium)
		generator.prepare()
		generator.impactOccurred()
		
		return configuration
	}
	
	override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) as? DateEventCell {
			UIView.animate(withDuration: 0.2) {
				cell.containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
				cell.containerView.layer.shadowOpacity = 0.2
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		if let indexPath = indexPath,
		   let cell = tableView.cellForRow(at: indexPath) as? DateEventCell {
			UIView.animate(withDuration: 0.2) {
				cell.containerView.transform = .identity
				cell.containerView.layer.shadowOpacity = 0.1
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
}

// MARK: - Drag & Drop Support
extension RootViewController: UITableViewDragDelegate, UITableViewDropDelegate {
	func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		let event = events[indexPath.row]
		let itemProvider = NSItemProvider(object: event.title as NSString)
		let dragItem = UIDragItem(itemProvider: itemProvider)
		dragItem.localObject = event
		return [dragItem]
	}
	
	func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
		return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
	}
	
	func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
		guard let destinationIndexPath = coordinator.destinationIndexPath,
			  let item = coordinator.items.first,
			  let sourceIndexPath = item.sourceIndexPath,
			  let event = item.dragItem.localObject as? DateEvent else { return }
		
		tableView.performBatchUpdates({
			events.remove(at: sourceIndexPath.row)
			events.insert(event, at: destinationIndexPath.row)
			tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
			tableView.insertRows(at: [destinationIndexPath], with: .automatic)
		})
		
		coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
		saveEvents()
	}
}
