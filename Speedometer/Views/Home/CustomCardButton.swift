//
//  CustomCardButton.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/27.
//

import UIKit

class CustomCardButton: CustomRoundButton {

    let cardImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    let cardLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(cardImage)
        self.addSubview(cardLabel)

        NSLayoutConstraint.activate([
            // 이미지 설정 - 너비가 버튼의 0.3, 비율 1:1, leading과 top에 간격 20.
            cardImage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            cardImage.heightAnchor.constraint(equalTo: cardImage.widthAnchor),
            cardImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            cardImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),

            // 레이블 설정 - 버튼 중앙에 위치.
            cardLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            cardLabel.centerXAnchor.constraint(equalTo:self.centerXAnchor),
            cardLabel.centerYAnchor.constraint(equalTo:self.centerYAnchor)

           // 추가적으로 필요한 제약조건들은 여기에 작성하세요.
           // 예를 들어 이미지뷰가 버튼 아래쪽으로 넘치지 않도록 하려면 아래와 같은 제약조건을 추가할 수 있습니다:
           //cardImage.bottomAnchor.constraint(lessThanOrEqualTo:self.bottomAnchor)

           // 또는 버튼의 크기가 내용물에 맞춰져서 자동으로 조절되도록 하려면 아래와 같은 제약조건을 추가할 수 있습니다:
           //self.bottomAnchor.constraint(greaterThanOrEqualTo:imageView.bottomAnchor, constant:20)

       ])
   }

    override func layoutSubviews() {
        DispatchQueue.main.async {
            self.updateCornerRadius(view: self.cardImage)
        }
    }

   required init?(coder aDecoder:NSCoder) {
       super.init(coder:aDecoder)
   }
}
