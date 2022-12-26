//
//  ViewController.m
//  Example
//
//  Created by gupengling on 2022/2/19.
//

#import "ViewController.h"
#import "Example-Swift.h"
#import <Masonry.h>

@import ACCodeTextLabel;

@interface ViewController ()<ACCodeTextLabelDelegate>
{
    ACCodeTextLabel *_temTextField;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    __block ACCodeTextLabel *temTextField = [[ACCodeTextLabel alloc]
                                             initWithLength:5
                                             charSpacing:10
                                             validCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]
                                             charLabelGenerator:^id<CodeProtocol> _Nonnull(NSInteger index) {
        if (index%2 == 0) {
            NormalStyleLabel *label = [[NormalStyleLabel alloc] initWithSize:CGSizeMake(50, 50)];
            label.errorColor = [UIColor greenColor];
            label.lineHeight = 3.0;
            return label;
        } else {
            NormalStyleLabel *label = [[NormalStyleLabel alloc] initWithSize:CGSizeMake(50, 50)];
            label.errorColor = [UIColor orangeColor];
            label.lineHeight = 4.0;
            label.radius = 4.0;
            [label setStyleWithType:StyleOCBorder normal:[UIColor grayColor] selected:[UIColor orangeColor]];
            return label;
        }
    }];
    _temTextField = temTextField;
    temTextField.keyboardType = UIKeyboardTypeNumberPad;
    temTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:temTextField];
    temTextField.backgroundColor = [UIColor lightGrayColor];
    temTextField.codeDelegate = self;

    __weak ACCodeTextLabel *weaktemTextField = temTextField;
    [temTextField setValueChanged:^(NSString * _Nonnull value) {
        NSLog(@"value = %@", value);
    }];
    [temTextField setValueEndChanged:^(NSString * _Nonnull value) {
        NSLog(@"end value = %@", value);
        [weaktemTextField resignFirstResponder];
    }];

    [temTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(200);
        make.height.mas_equalTo(50);
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [temTextField becomeFirstResponder];
    });

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_temTextField.isError = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->_temTextField.isError = NO;
        });
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
    TestViewController *vc = [[TestViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)codeTextFieldValueChanged:(ACCodeTextLabel *)sender value:(NSString *)value {
    NSLog(@"delegate value = %@", value);

}
- (void)codeTextFieldValueEndChanged:(ACCodeTextLabel *)sender value:(NSString *)value {
    NSLog(@"delegate end value = %@", value);
    [sender resignFirstResponder];
}
@end
