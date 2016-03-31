//
//  ViewController.m
//  testcoreImage
//
//  Created by Sunny on 16/3/25.
//  Copyright © 2016年 sunny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *tiImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)pickimage:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //设置拍照后的图片可被编辑
//    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController: picker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        self.tiImageView.image = image;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getMouthsImage:image];
        });
        
    }

}

- (void)getMouthsImage:(UIImage *)image
{
    
    CIImage* cgImage = [CIImage imageWithCGImage:image.CGImage];
    
    NSDictionary  *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                      forKey:CIDetectorAccuracy];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:opts];
    
    //得到面部数据
    NSArray* features = [detector featuresInImage:cgImage];
    CIFaceFeature *feature = nil;
    CGRect rect;
    for (CIFaceFeature *f in features)
    {
        CGRect aRect = f.bounds;
        NSLog(@"%f, %f, %f, %f", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
        
        //眼睛和嘴的位置
        if(f.hasLeftEyePosition) NSLog(@"Left eye %g %g\n", f.leftEyePosition.x, f.leftEyePosition.y);
        if(f.hasRightEyePosition) NSLog(@"Right eye %g %g\n", f.rightEyePosition.x, f.rightEyePosition.y);
        if(f.hasMouthPosition)
        {
            NSLog(@"Mouth %g %g %g %g\n", f.mouthPosition.x, f.mouthPosition.y,f.bounds.size.height,f.bounds.size.width);
            feature = f;
            rect = CGRectMake(f.mouthPosition.x - 100 , f.mouthPosition.y  - 60, 200, 250);
        }
    }
    
    if (feature) {
        CGImageRef cgImageRef = [[CIContext contextWithOptions:nil] createCGImage:cgImage fromRect:rect];
        self.tiImageView.image = [UIImage imageWithCGImage:cgImageRef scale:1.0 orientation:UIImageOrientationRight];
        CGImageRelease(cgImageRef);
    }

    
}

// 取消选取
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

@end
