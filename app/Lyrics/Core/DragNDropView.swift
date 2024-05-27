//
//  DragNDropView.swift
//  Lyrics
//
//  https://github.com/ddddxxx/LyricsX/blob/master/LyricsX/View/DragNDropView.swift
//

import Foundation
import Cocoa

protocol DragNDropDelegate: AnyObject {
    func dragFinished(content: String)
}

class DragNDropView: NSView {
    
    weak var dragDelegate: DragNDropDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.string, .fileNames])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        
        if pboard.types?.contains(.string) == true,
            let str = pboard.string(forType: .string) {
            dragDelegate?.dragFinished(content: str)
            return true
        }
        
        do {
            if pboard.types?.contains(.fileNames) == true,
                let files = pboard.propertyList(forType: .fileNames) as? [Any],
                let path = files.first as? String {
                let str = try String(contentsOf: URL(fileURLWithPath: path))
                dragDelegate?.dragFinished(content: str)
                return true
            } else {
                let errorInfo = [
                    NSLocalizedDescriptionKey: "Fail to import lyrics",
                    NSLocalizedFailureReasonErrorKey: "The file couldn’t be opened."
                ]
                let error = NSError(domain: "likeai.lyrics", code: 0, userInfo: errorInfo)
                throw error
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
            return false
        }
    }
    
}

extension NSPasteboard.PasteboardType {
    static let fileNames = NSPasteboard.PasteboardType("NSFilenamesPboardType")
}
