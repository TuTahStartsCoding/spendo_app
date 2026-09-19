// lib/widgets/custom_button.dart
// Widget ปุ่มที่ปรับแต่งได้ - ใช้ทั่วทั้งแอป
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  // ข้อความบนปุ่ม
  final String text;
  
  // สีพื้นหลังปุ่ม
  final Color backgroundColor;
  
  // สีข้อความ
  final Color textColor;
  
  // ฟังก์ชันเมื่อกดปุ่ม
  final VoidCallback? onPressed;
  
  // ไอคอนบนปุ่ม (ไม่บังคับ)
  final IconData? icon;
  
  // ขนาดความกว้าง
  final double? width;
  
  // ขนาดความสูง
  final double? height;
  
  // ขนาดฟอนต์
  final double fontSize;
  
  // น้ำหนักฟอนต์
  final FontWeight fontWeight;
  
  // รัศมีมุม
  final double borderRadius;
  
  // ความหนาเงา
  final double elevation;
  
  // สถานะการโหลด
  final bool isLoading;
  
  // สี loading indicator
  final Color loadingColor;
  
  // ขนาด loading indicator
  final double loadingSize;
  
  const CustomButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 48,
    this.fontSize = AppFontSizes.medium,
    this.fontWeight = FontWeight.bold,
    this.borderRadius = AppRadius.large,
    this.elevation = 3,
    this.isLoading = false,
    this.loadingColor = Colors.white,
    this.loadingSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: onPressed == null ? 0 : elevation,
          shadowColor: backgroundColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        child: isLoading
            ? _buildLoadingContent()
            : _buildButtonContent(),
      ),
    );
  }
  
  // สร้างเนื้อหาปุ่มปกติ
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: fontSize + 2,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.notoSansThai(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: GoogleFonts.notoSansThai(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
  
  // สร้างเนื้อหาปุ่มแบบ loading
  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: loadingSize,
          height: loadingSize,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.notoSansThai(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ปุ่มแบบ Outlined
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final bool isLoading;
  
  const CustomOutlinedButton({
    Key? key,
    required this.text,
    required this.borderColor,
    required this.textColor,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 48,
    this.fontSize = AppFontSizes.medium,
    this.fontWeight = FontWeight.bold,
    this.borderRadius = AppRadius.large,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    text,
                    style: GoogleFonts.notoSansThai(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
                  ),
                ],
              )
            : (icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: textColor, size: fontSize + 2),
                      SizedBox(width: 8),
                      Text(
                        text,
                        style: GoogleFonts.notoSansThai(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: textColor,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: GoogleFonts.notoSansThai(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
                  )),
      ),
    );
  }
}

// ปุ่มแบบ Text
class CustomTextButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double fontSize;
  final FontWeight fontWeight;
  
  const CustomTextButton({
    Key? key,
    required this.text,
    required this.textColor,
    this.onPressed,
    this.icon,
    this.fontSize = AppFontSizes.medium,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: textColor, size: fontSize),
                SizedBox(width: 4),
                Text(
                  text,
                  style: GoogleFonts.notoSansThai(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: GoogleFonts.notoSansThai(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
    );
  }
}

// ปุ่มแบบ Floating Action Button
class CustomFloatingButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;
  
  const CustomFloatingButton({
    Key? key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onPressed,
    this.size = 56,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        tooltip: tooltip,
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.4,
        ),
      ),
    );
  }
}

// ปุ่มแบบ Icon
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;
  final double size;
  final double borderRadius;
  final String? tooltip;
  
  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onPressed,
    this.size = 48,
    this.borderRadius = AppRadius.medium,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: iconColor,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}