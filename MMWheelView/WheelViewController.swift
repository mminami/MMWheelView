//
//  WheelViewController.swift
//  MMWheelView
//
//  Created by mminami on 2017/12/10.
//  Copyright © 2017 mminami. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class WheelViewController: UIViewController, WheelViewDataSource {
    lazy var wheelView: WheelView = {
        let view = WheelView()
        view.dataSource = self
        view.circleColor = .white
        view.circleRadius = 150
        view.backgroundColor = .black
        return view
    }()

    lazy var closeButton: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.title = "Close"
        item.style = .done
        return item
    }()

    private let disposeBag = DisposeBag()

    let imageUrls = ["https://contents.newspicks.us/users/100013/cover?circle=true",
                     "https://contents.newspicks.us/users/100269/cover?circle=true",
                     "https://contents.newspicks.us/users/100094/cover?circle=true",
                     "https://contents.newspicks.us/users/100353/cover?circle=true",
                     "https://contents.newspicks.us/users/100019/cover?circle=true",
                     "https://contents.newspicks.us/users/100529/cover?circle=true"]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = closeButton

        view.backgroundColor = .black

        view.addSubview(wheelView)

        closeButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        wheelView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        wheelView.startRotating()
    }
}

extension WheelViewController {
    func numberOfBaskets(in wheelView: WheelView) -> Int {
        return imageUrls.count
    }

    func wheelView(_ view: WheelView, basketForRowAt index: Int) -> Basket {
        let basket = Basket(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        basket.imageView.kf.setImage(with: URL(string: imageUrls[index])!,
                                     placeholder: UIImage(named: "no_img"))
        view.backgroundColor = .clear
        return basket
    }
}
