//
//  SceneSelectViewController.swift
//  FeasyHome2
//
//  Created by wenjie zeng on 2025/2/11.
//

import UIKit
import SDWebImage

class SceneSelectViewController: UIViewController {
    var sceneItemList:[SceneItem] = []
    var sceneCollectionView:UICollectionView!
    var selectedIndexPath:IndexPath!
    var selectSceneCallback:((SceneItem)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.navigationItem.title = "选择场景"
        
        self.fetchSceneConfigList()
        setupUI()
    }
    
    private func fetchSceneConfigList() {
        SceneNetManager.shareInstance.fetchSceneConfigList(familyId: kCurrentFamilyID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                self.sceneItemList = response
                DispatchQueue.main.async {
                    self.sceneCollectionView.reloadData()
                }
            case .failure(let error):
                print("error=\(error)")
            }
        }
    }
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = kScreen_Width*15.0/375
        layout.itemSize = CGSize(width: kScreen_Width*160.0/375, height: kScreen_Width*100.0/375)
        
        sceneCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        sceneCollectionView.delegate = self
        sceneCollectionView.dataSource = self
        sceneCollectionView.backgroundColor = UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)
        sceneCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SceneSelectCollectionViewCell")
        self.view.addSubview(sceneCollectionView)
        sceneCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 20),
            sceneCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            sceneCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            sceneCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -90)])
        
        let btnSelect  = UIButton(type: .system)
        btnSelect.setTitle("选择场景", for: .normal)
        self.view.addSubview(btnSelect)
        btnSelect.tintColor = .white
        btnSelect.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btnSelect.backgroundColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        btnSelect.layer.cornerRadius = 6
        btnSelect.translatesAutoresizingMaskIntoConstraints = false;
        btnSelect.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-35)
            make.height.equalTo(48)
        }
        btnSelect.addTarget(self, action: #selector(btnSelectAction), for: .touchUpInside)
    }
    
    @objc private func btnSelectAction() {
        if let selectedIndexPath, let selectSceneCallback = selectSceneCallback {
            let sceneCodeList =  [sceneItemList[selectedIndexPath.item].sceneCode]
            
            SceneNetManager.shareInstance.addScene(familyId: kCurrentFamilyID, sceneCodeList: sceneCodeList) { result in
                switch result {
                case .success(let result):
                    print("result=\(result)")
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
            }
            
            selectSceneCallback(sceneItemList[selectedIndexPath.item])
            navigationController?.popViewController(animated: true)
        } else {
            self.showToast("请选择场景")
        }
    }
}

extension SceneSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sceneItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SceneSelectCollectionViewCell", for: indexPath)
        
        let imgView = UIImageView()
        imgView.sd_setImage(with: URL(string: baseURL+sceneItemList[indexPath.item].sceneImageUrl))
        cell.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.width.equalTo(kScreen_Width*160.0/375)
            make.height.equalTo(kScreen_Width*100.0/375)
        }
        let lable = UILabel(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
        lable.text = sceneItemList[indexPath.item].sceneName
        lable.textColor = .white
        imgView.addSubview(lable)
        lable.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-5)
            make.centerX.equalToSuperview()
        }
        if indexPath == selectedIndexPath {
            cell.layer.borderColor = UIColor.red.cgColor
            cell.layer.borderWidth = 2.0
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0.0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            if let orgSelectedIndexPath = selectedIndexPath {
                selectedIndexPath = indexPath
                collectionView.reloadItems(at: [orgSelectedIndexPath])
            }
            selectedIndexPath = indexPath
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPath = nil
        collectionView.reloadItems(at: [indexPath])
    }
}
