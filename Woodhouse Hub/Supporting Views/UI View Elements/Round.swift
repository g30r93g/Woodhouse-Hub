//
//  Round.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 14/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

// A round UIView
@IBDesignable
class RoundView: UIView {
	
	@IBInspectable var cornerRadius: CGFloat = 0.0 {
		didSet {
			layer.cornerRadius = cornerRadius
		}
	}
	
	@IBInspectable var borderColor: UIColor = .clear {
		didSet {
			layer.borderColor = borderColor.cgColor
		}
	}
	
	@IBInspectable var borderWidth: CGFloat = 0.0 {
		didSet {
			layer.borderWidth = borderWidth
		}
	}
	
}

// A UIView that has the top corners rounded
@IBDesignable
class RoundTopView: UIView {
	
	@IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
           self.updateCornerRadius()
        }
    }
	
	private func updateCornerRadius() {
		self.layer.cornerRadius = cornerRadius
		self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
	}
	
}

// A round UIButton
@IBDesignable
class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
	
	@IBInspectable var imageAngle: CGFloat = 0.0 {
		didSet {
			self.imageView?.transform = CGAffineTransform(rotationAngle: (imageAngle * .pi/180))
		}
	}
    
}

// A round UIImageView
@IBDesignable
class RoundImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
}

// A round UILabel
@IBDesignable
class RoundLabel: UILabel {
	
	var padding: UIEdgeInsets {
		return UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
	}
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
	
	@IBInspectable var labelAngle: CGFloat = 0.0 {
		didSet {
			self.transform = CGAffineTransform(rotationAngle: (labelAngle * .pi/180))
		}
	}
	
	@IBInspectable var leftPadding: CGFloat = 4.0 {
		didSet {
			applyPadding()
		}
	}
	
	@IBInspectable var topPadding: CGFloat = 4.0 {
		didSet {
			applyPadding()
		}
	}
	
	@IBInspectable var rightPadding: CGFloat = 4.0 {
		didSet {
			applyPadding()
		}
	}
	
	@IBInspectable var bottomPadding: CGFloat = 4.0 {
		didSet {
			applyPadding()
		}
	}
	
	func applyPadding() {
		self.frame.inset(by: self.padding)
	}
	
}

// A round UITableView
@IBDesignable
class RoundTableView: UITableView {
	
	@IBInspectable var cornerRadius: CGFloat = 0.0 {
		didSet {
			layer.cornerRadius = cornerRadius
		}
	}
	
	@IBInspectable var borderColor: UIColor = .clear {
		didSet {
			layer.borderColor = borderColor.cgColor
		}
	}
	
	@IBInspectable var borderWidth: CGFloat = 0.0 {
		didSet {
			layer.borderWidth = borderWidth
		}
	}
	
}

// A round UICollectionViewCell
@IBDesignable
class RoundUICollectionViewCell: UICollectionViewCell {
	
	@IBInspectable var cornerRadius: CGFloat = 0.0 {
		didSet {
			layer.cornerRadius = cornerRadius
		}
	}
	
}

// A round visual effect view
@IBDesignable
class RoundVisualView: UIVisualEffectView {
	
	@IBInspectable var cornerRadius: CGFloat = 0.0 {
		didSet {
			layer.cornerRadius = cornerRadius
		}
	}
	
}
