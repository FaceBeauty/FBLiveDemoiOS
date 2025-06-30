
#import "HomeViewController.h"
#import "CameraViewController.h"
#import <Masonry/Masonry.h>

@interface HomeViewController ()

@property(nonatomic,strong)UIButton *startBtn;

@end

@implementation HomeViewController

- (UIButton *)startBtn{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setBackgroundImage:[UIImage imageNamed:@"btn_kuaimen.png"] forState:UIControlStateNormal];
        [_startBtn setTitle:@"进入" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:233.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    [self.view addSubview:self.startBtn];
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-100);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
    
}

- (void)onClick:(UIButton *)sender{
    // function：0:美颜；1：贴纸；2：滤镜
    CameraViewController *CVC = [[CameraViewController alloc] initWithFunction:0];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:CVC];
    nav.navigationBarHidden = YES;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
