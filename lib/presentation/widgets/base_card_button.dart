import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseCardButton extends StatelessWidget {
  final String title;
  final String? description;
  final double? titleSize;
  final Color color;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const BaseCardButton({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    this.description,
    this.titleSize,
    this.backgroundColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.w,
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 48.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
            
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize ?? 12.w,
                          ),
                        ),
                        if (description != null) ...[
                          SizedBox(height: 4.w),
                          Text(
                            description!,
                            style: TextStyle(fontSize: 10.w),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CircleAvatar(
                    backgroundColor: color,
                    child: const Icon(Icons.double_arrow, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
