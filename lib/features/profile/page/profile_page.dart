import 'package:bontrack/core/cubit/auth/auth_cubit.dart';
import 'package:bontrack/core/cubit/auth/auth_state.dart';
import 'package:bontrack/features/profile/widget/profile_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = state.user;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32.h),
                ProfileMenuWidget(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profil',
                  onTap: () {},
                  isDestructive: false,
                ),
                ProfileMenuWidget(
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  onTap: () {},
                  isDestructive: false,
                ),
                ProfileMenuWidget(
                  icon: Icons.help_outline,
                  title: 'Bantuan',
                  onTap: () {},
                  isDestructive: false,
                ),
                SizedBox(height: 16.h),
                ProfileMenuWidget(
                  icon: Icons.logout,
                  title: 'Keluar',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Keluar', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
