import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_auction_app/authentication/bloc/auth_bloc.dart'; // Needed to provide AuthBloc to ProfileBloc
import 'package:car_auction_app/profile/bloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ProfileBloc depends on AuthBloc. AuthBloc should be accessible in the context.
    // This is typically achieved by providing AuthBloc higher up in the widget tree (e.g., in MyApp).
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocProvider<ProfileBloc>(
      // ProfileBloc is created here and receives the AuthBloc instance.
      // It automatically dispatches ProfileDataLoadRequested upon creation (see ProfileBloc constructor).
      create: (context) => ProfileBloc(authBloc: authBloc),
      child: const _ProfileScreenView(),
    );
  }
}

class _ProfileScreenView extends StatelessWidget {
  const _ProfileScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        // Assuming this screen is pushed onto a navigator stack (e.g., from SearchScreen)
        // A leading back button will be automatically added by Flutter if Navigator.canPop(context) is true.
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.logoutSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Logout successful! Returning to login...'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2), // Show for a bit before navigating
                ),
              );
            // Navigate back to login screen, clearing the navigation stack.
            // Adding a slight delay to allow SnackBar to be seen.
            Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) { // Check if widget is still in the tree
                    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
                }
            });
          } else if (state.status == ProfileStatus.logoutFailure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Logout failed: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
          } else if (state.status == ProfileStatus.error && state.errorMessage != null) {
             ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.orange,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                if (state.status == ProfileStatus.loaded && state.email != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          Icon(Icons.account_circle, size: 80, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Logged in as:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.email!,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.status == ProfileStatus.error || (state.status == ProfileStatus.loaded && state.email == null))
                  Center(
                    child: Text(
                      state.errorMessage ?? 'Could not load user email.',
                      style: TextStyle(color: Colors.red[700], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const Spacer(), // Pushes logout button to the bottom

                if (state.status == ProfileStatus.logoutInProgress)
                  const Center(child: Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: CircularProgressIndicator(),
                  ))
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), // Add some padding at the bottom
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        context.read<ProfileBloc>().add(ProfileLogoutButtonPressed());
                      },
                    ),
                  ),
                if (state.status == ProfileStatus.logoutFailure && state.errorMessage != null && state.status != ProfileStatus.logoutInProgress)
                  Padding( // Only show if not already showing loading indicator
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Logout Error: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}