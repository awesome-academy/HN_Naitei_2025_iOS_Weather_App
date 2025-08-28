//
//  SearchDropdownView.swift
//  WeatherApp
//
//  Created by Phan Quyen on 28/08/2025.
//

import UIKit

protocol SearchDropdownDelegate: AnyObject {
    func didSelectSearchSuggestion(_ suggestion: String)
}

class SearchDropdownView: UIView {
    
    private let tableView = UITableView()
    private var suggestions: [String] = []
    
    weak var delegate: SearchDropdownDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 8
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func updateSuggestions(_ suggestions: [String]) {
        self.suggestions = suggestions
        tableView.reloadData()
        
        if suggestions.isEmpty {
            isHidden = true
        } else {
            isHidden = false
            superview?.bringSubviewToFront(self)
        }
    }
    
    func hide() {
        isHidden = true
        suggestions.removeAll()
        tableView.reloadData()
    }
}

extension SearchDropdownView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        
        cell.textLabel?.text = suggestions[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = .darkGray
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let iconImage = UIImage(systemName: "clock.arrow.circlepath")
        cell.imageView?.image = iconImage
        cell.imageView?.tintColor = .lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        delegate?.didSelectSearchSuggestion(suggestion)
        hide()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
