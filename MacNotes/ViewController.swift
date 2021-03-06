//
//  ViewController.swift
//  MacNotes
//
//  Created by Antony Yurchenko on 11/4/17.
//  Copyright © 2017 Antony Yurchenko. All rights reserved.
//

import Cocoa
import Storage

class ViewController: NSViewController {
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet var textView: NSTextView!
	@IBOutlet weak var textField: NSTextField!
	@IBOutlet weak var addBtn: NSButton!
	@IBOutlet weak var removeBtn: NSButton!
	
	var lastIndexCell = 0
	
	var storage = LocalStorage()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		textView.delegate = self
		textField.delegate = self
		
		addBtn.isEnabled = false
		removeBtn.isEnabled = false
		textView.isEditable = false
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		storage.load()
		tableView.reloadData()
	}
	
	@IBAction func onAddBtnClick(_ sender: NSButton) {
		let title = textField.stringValue
		storage.add(index: tableView.selectedRow, note: Note(title: title, text: ""))
		
		tableView.reloadData()
		
		textView.textStorage?.mutableString.setString("")
		
		textField.stringValue.removeAll()
		addBtn.isEnabled = false
		
		tableView.selectRowIndexes(IndexSet(integer: storage.notes.count - 1), byExtendingSelection: false)
	}
	
	@IBAction func onRemoveBtnClick(_ sender: NSButton) {
		let index = tableView.selectedRow
		
		if !storage.notes[index].title.isEmpty {
			storage.delete(index: index)
			
			tableView.reloadData()
			textView.textStorage?.mutableString.setString("")
			textView.isEditable = false
			removeBtn.isEnabled = false
		}
	}
}

extension ViewController : NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate, NSTextFieldDelegate {
	
	static let noteCell = "NoteCellID"
	
	// MARK: NSTableViewDataSource
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return storage.notes.count
	}
	
	// MARK: NSTableViewDelegate
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var title = ""
		
		let item = storage.notes[row]
		
		if tableColumn == tableView.tableColumns[0] {
			title = item.title
		}
		
		if let cell = tableView.make(withIdentifier: ViewController.noteCell, owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = title
			cell.textField?.textColor = NSColor(calibratedHue: 0.1, saturation: 0.1, brightness: 0.1, alpha: 1.0)
			return cell
		}
		
		return nil
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		let selectedIndexCell = tableView.selectedRow
		
		if selectedIndexCell < 0 {
			tableView.selectRowIndexes(IndexSet(integer: lastIndexCell), byExtendingSelection: false)
			return
		}
		
		lastIndexCell = selectedIndexCell
		
		textView.isEditable = true
		removeBtn.isEnabled = true
		
		textView.textStorage?.mutableString.setString("")
		
		let title = storage.notes[selectedIndexCell].title
		
		for note in storage.notes where note.title == title {
			textView.textStorage?.mutableString.append(note.text)
		}
	}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		return MyNSTableRowView()
	}
	
	// MARK: NSTextViewDelegate
	
	func textDidChange(_ notification: Notification) {
		let text = textView.attributedString().string
		let title = storage.notes[tableView.selectedRow].title
		
		storage.update(index: tableView.selectedRow, note: Note(title: title, text: text))
	}
	
	// MARK: NSTextFieldDelegate
	
	override func controlTextDidChange(_ obj: Notification) {
		let text = textField.stringValue
		addBtn.isEnabled = !text.isEmpty
	}
}

// MARK: views subclass

class MyNSTableRowView : NSTableRowView {
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if isSelected == true {
			NSColor(red:0.99, green:0.88, blue:0.55, alpha:1.0).set()
			NSRectFill(dirtyRect)
		}
	}
}
