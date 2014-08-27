//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Component<S> {
	/// The state on which the component depends.
	public var state: S {
		didSet {
			if shouldUpdate(oldValue, newState: state) {
				update()
			}
		}
	}

	private let render: S -> Element
	
	// Ugh. These should be Component<S> but Xcode 6b6 hangs on launch if we do 
	// that.
	private let didRealize: (Any -> ())?
	private let willDerealize: (Any -> ())?

	private var topElement: Element

	private var hostView: NSView?

	public init(render: S -> Element, initialState: S, didRealize: (Any -> ())? = nil, willDerealize: (Any -> ())? = nil) {
		self.render = render
		self.state = initialState
		self.didRealize = didRealize
		self.willDerealize = willDerealize
		self.topElement = render(initialState)
	}

	private func update() {
		let otherElement = render(state)

		// If we can diff then apply it. Otherwise we just swap out the entire
		// hierarchy.
		if topElement.canDiff(otherElement) {
			topElement.applyDiff(otherElement)
		} else {
			topElement.derealize()
			topElement = otherElement

			if let hostView = hostView {
				topElement.realize(self, parentView: hostView)
			}
		}
	}
	
	// MARK: Lifecycle
	
	/// Called when the component has been realized.
	public func componentDidRealize() {
		didRealize?(self)
	}
	
	/// Called when the component is about to be derealized.
	public func componentWillDerealize() {
		willDerealize?(self)
	}
	
	/// Called when the state has changed but before the component is 
	/// re-rendered. This gives the component the chance to decide whether it 
	/// *should* based on the new state.
	///
	/// The default implementation always returns true.
	public func shouldUpdate(previousState: S, newState: S) -> Bool {
		return true
	}
	
	// MARK: -

	/// Add the component to the given view.
	public func addToView(view: NSView) {
		hostView = view
		topElement.realize(self, parentView: view)
		
		componentDidRealize()
	}
	
	/// Remove the component from its host view.
	public func remove() {
		componentWillDerealize()
		
		topElement.derealize()
		hostView = nil
	}
	
	public func getContentView() -> NSView? {
		return topElement.getContentView()
	}
	
	public func getIntrinsicSize() -> CGSize {
		return topElement.getIntrinsicSize()
	}
}
