import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../data/auction_data_model.dart'; // Required for AuctionData and AuctionDataChoice

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _vinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  void _submitVin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<SearchBloc>().add(VinSubmitted(_vinController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIN Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'Enter VIN (17 characters)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 17,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a VIN.';
                  }
                  if (value.length != 17) {
                    return 'VIN must be 17 characters long.';
                  }
                  // Basic regex for allowed characters (can be more specific)
                  if (!RegExp(
                    r'^[A-HJ-NPR-Z0-9]+$',
                  ).hasMatch(value.toUpperCase())) {
                    return 'VIN contains invalid characters (I, O, Q not allowed).';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitVin(),
              ),
              const SizedBox(height: 16),
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is SearchLoading ? null : _submitVin,
                    child: state is SearchLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Search VIN'),
                  );
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return const Center(
                        child: Text('Please enter a VIN to search.'),
                      );
                    }
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchSuccessSingleItem) {
                      return _buildSuccessSingleItem(state.auctionData);
                    }
                    if (state is SearchSuccessMultipleItems) {
                      return _buildSuccessMultipleItems(
                        state.auctionDataChoices,
                      );
                    }
                    if (state is SearchFailure) {
                      return _buildFailureWidget(state);
                    }
                    return const Center(
                      child: Text('Unknown state.'),
                    ); // Should not happen
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessSingleItem(AuctionData data) {
    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auction Data Found:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('ID: ${data.id}'),
              Text('Make: ${data.make}'),
              Text('Model: ${data.model}'),
              Text('External ID: ${data.externalId}'),
              if (data.price != null) Text('Price: ${data.price}'),
              if (data.feedback != null) Text('Feedback: "${data.feedback}"'),
              if (data.origin != null) Text('Origin: ${data.origin}'),
              if (data.valuatedAt != null) Text('Valuated At: ${data.valuatedAt}'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.gavel),
                  label: const Text('View Auction'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/auction',
                      arguments: {
                        'uuid': data.externalId,
                        'model': data.model,
                        'price': data.price.toString(),
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMultipleItems(List<AuctionDataChoice> choices) {
    if (choices.isEmpty) {
      return const Center(child: Text('No choices found for the VIN.'));
    }
    choices.sort((a, b) => b.similarity.compareTo(a.similarity));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Multiple Results Found:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final choice = choices[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text('${choice.make} ${choice.model}'),
                  subtitle: Text(
                    'Container: ${choice.containerName}\nSimilarity: ${choice.similarity}% \nExt. ID: ${choice.externalId}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFailureWidget(SearchFailure state) {
    return Center(
      child: Card(
        elevation: 2,
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 40),
              const SizedBox(height: 12),
              Text(
                'Error: ${state.error}',
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.resolutionSuggestion != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.resolutionSuggestion!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              if (state.serverErrorDetails != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Server Details: ${state.serverErrorDetails!.msgKey} - ${state.serverErrorDetails!.message}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
