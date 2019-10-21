//
//  ViewController.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 14/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController {

    @IBOutlet weak var peripheralsTableView : UITableView!
    
    var peripheralDevices                   : [CBPeripheral]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManager()
        peripheralsTableView.delegate = self
        peripheralsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPeripheralDetails" {
            guard let _ = segue.destination as? DetailViewController else { return }
        }
    }
}

extension ViewController {
    func initManager() {
        BLEManager.shared.setDeviceName(deviceName: "Brilliantly Warm")
        BLEManager.shared.addNewPeripheralToList = { [weak self] allDevices in
            self?.peripheralDevices = allDevices
            self?.peripheralsTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralDevices?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = peripheralDevices?[indexPath.row].name ?? "No name"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        BLEManager.shared.connectToPeripheral(at: indexPath.row)
        performSegue(withIdentifier: "showPeripheralDetails", sender: nil)
    }
}
