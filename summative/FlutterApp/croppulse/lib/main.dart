import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CropPulseApp());
}

class CropPulseApp extends StatelessWidget {
  const CropPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining the colors to use throughout the app for consistency and easy maintenance
    const bgColor = Color(0xFF222836);
    const cardColor = Color(0xFF2A3040);
    const accentColor = Color(0xFFC778DD);
    const textColor = Color(0xFFF5F5F5);
    const secondaryTextColor = Color(0xFFABB2BF);

    final baseTextTheme = GoogleFonts.ibmPlexMonoTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CropPulse',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        primaryColor: accentColor,
        colorScheme: const ColorScheme.dark(
          primary: accentColor,
          surface: cardColor,
          secondary: accentColor,
        ),
        textTheme: baseTextTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF222836),
          hintStyle: const TextStyle(color: secondaryTextColor),
          labelStyle: const TextStyle(color: secondaryTextColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF49516A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accentColor, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
      home: const CropPulseHomePage(),
    );
  }
}

class CropPulseHomePage extends StatefulWidget {
  const CropPulseHomePage({super.key});

  @override
  State<CropPulseHomePage> createState() => _CropPulseHomePageState();
}

class _CropPulseHomePageState extends State<CropPulseHomePage> {
  static const String baseUrl =
      'https://cropproductionpredictionapi.onrender.com';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  String? _selectedCrop;
  String _resultMessage = 'Prediction result will appear here.';
  bool _predictionIsError = false;
  bool _isPredicting = false;

  PlatformFile? _selectedFile;
  bool _isTraining = false;
  bool _trainingIsError = false;
  String _trainMessage =
      'Upload a dataset in the required CSV format to retrain the model.';

  final List<String> _cropItems = const [
    'Avocados',
    'Bananas',
    'Beans, dry',
    'Cabbages',
    'Carrots and turnips',
    'Cassava, fresh',
    'Chillies and peppers, green (Capsicum spp. and Pimenta spp.)',
    'Coffee, green',
    'Eggplants (aubergines)',
    'Groundnuts, excluding shelled',
    'Leeks and other alliaceous vegetables',
    'Lemons and limes',
    'Maize (corn)',
    'Mangoes, guavas and mangosteens',
    'Millet',
    'Onions and shallots, dry (excluding dehydrated)',
    'Oranges',
    'Other beans, green',
    'Other fruits, n.e.c.',
    'Other stimulant, spice and aromatic crops, n.e.c.',
    'Other tropical fruits, n.e.c.',
    'Other vegetables, fresh n.e.c.',
    'Papayas',
    'Peas, dry',
    'Pepper (Piper spp.), raw',
    'Pineapples',
    'Plantains and cooking bananas',
    'Potatoes',
    'Pumpkins, squash and gourds',
    'Pyrethrum, dried flowers',
    'Rice',
    'Sorghum',
    'Soya beans',
    'Sugar cane',
    'Sweet potatoes',
    'Taro',
    'Tea leaves',
    'Tomatoes',
    'Unmanufactured tobacco',
    'Wheat',
    'Yams',
  ];

  @override
  void dispose() {
    _yearController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _predictProduction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCrop == null) {
      setState(() {
        _predictionIsError = true;
        _resultMessage = 'Please select a crop before prediction.';
      });
      return;
    }

    setState(() {
      _isPredicting = true;
      _predictionIsError = false;
      _resultMessage = 'Predicting...';
    });

    try {
      final year = int.parse(_yearController.text.trim());
      final area = double.parse(_areaController.text.trim());

      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'year': year,
          'area_ha': area,
          'item_name': _selectedCrop,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prediction = decoded['The predicted production is'];
        setState(() {
          _predictionIsError = false;
          _resultMessage =
              'Predicted production: ${double.parse(prediction.toString()).toStringAsFixed(2)} tonnes';
        });
      } else {
        setState(() {
          _predictionIsError = true;
          _resultMessage =
              decoded['detail']?.toString() ??
              'Prediction failed. Please check your values.';
        });
      }
    } catch (e) {
      setState(() {
        _predictionIsError = true;
        _resultMessage = 'Something went wrong while predicting: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
      }
    }
  }

  Future<void> _pickDataset() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _trainingIsError = false;
        _trainMessage = 'Selected file: ${_selectedFile!.name}';
      });
    }
  }

  Future<void> _retrainModel() async {
    if (_selectedFile == null) {
      setState(() {
        _trainingIsError = true;
        _trainMessage = 'Please choose a CSV dataset before training.';
      });
      return;
    }

    setState(() {
      _isTraining = true;
      _trainingIsError = false;
      _trainMessage = 'Training the model... please wait.';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/retrain'),
      );

      if (_selectedFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );
      } else if (_selectedFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _selectedFile!.path!,
            filename: _selectedFile!.name,
          ),
        );
      } else {
        throw Exception('Could not read selected file.');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final rowsUsed = decoded['rows_used'];
        final featuresUsed = decoded['features_used'];

        setState(() {
          _trainingIsError = false;
          _trainMessage =
              'Model retrained successfully.\nRows used: $rowsUsed\nFeatures used: $featuresUsed';
        });
      } else {
        setState(() {
          _trainingIsError = true;
          _trainMessage =
              decoded['detail']?.toString() ??
              'Retraining failed. Please verify the uploaded dataset.';
        });
      }
    } catch (e) {
      setState(() {
        _trainingIsError = true;
        _trainMessage = 'Something went wrong while retraining: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTraining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 760 && width < 1100;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 600 ? 16 : 28,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeaderSection(),
                      const SizedBox(height: 28),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPredictionCard()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildRetrainCard()),
                          ],
                        )
                      else if (isTablet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPredictionCard()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildRetrainCard()),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildPredictionCard(),
                            const SizedBox(height: 24),
                            _buildRetrainCard(),
                          ],
                        ),
                      const SizedBox(height: 28),
                      const _FooterCard(),
                    ],
                  ),
                ),
              ),
            ),
            if (_isTraining)
              Container(
                color: Colors.black.withOpacity(0.36),
                child: const Center(child: _LoadingOverlayCard()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return _SectionCard(
      title: '#predict-production',
      subtitle:
          'Enter the required values below to estimate crop production using the deployed regression model (it uses Random Forest Regression Model trained on the dataset).',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g. 2020',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Year is required';
                }
                final year = int.tryParse(value.trim());
                if (year == null) {
                  return 'Enter a valid year';
                }
                if (year < 1900 || year > 2100) {
                  return 'Year must be between 1900 and 2100';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Area harvested (ha)',
                hintText: 'e.g. 150.5',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Area is required';
                }
                final area = double.tryParse(value.trim());
                if (area == null) {
                  return 'Enter a valid area';
                }
                if (area <= 0) {
                  return 'Area must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedCrop,
              isExpanded: true,
              dropdownColor: const Color(0xFF2A3040),
              decoration: const InputDecoration(labelText: 'Crop name'),
              iconEnabledColor: Colors.white,
              selectedItemBuilder: (context) {
                return _cropItems.map((crop) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      crop,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  );
                }).toList();
              },
              items: _cropItems.map((crop) {
                return DropdownMenuItem<String>(
                  value: crop,
                  child: Tooltip(
                    message: crop,
                    child: Text(
                      crop,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a crop';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isPredicting ? null : _predictProduction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC778DD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isPredicting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Predict',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 22),
            _ResultPanel(
              title: 'Prediction output',
              message: _resultMessage,
              isError: _predictionIsError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetrainCard() {
    return _SectionCard(
      title: '#retrain-model',
      subtitle:
          'Upload a valid dataset in the expected CSV format to update the current model for future predictions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF222836),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC778DD).withOpacity(0.85),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dataset upload',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Accepted file type: CSV\nExpected structure: Item, Year, Area (ha), Area Flag, Yield (hg/ha), Yield Flag, Production (tonnes), Production Flag',
                  style: TextStyle(color: Color(0xFFABB2BF), height: 1.65),
                ),
                const SizedBox(height: 16),
                Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isTraining ? null : _pickDataset,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC778DD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Choose dataset'),
                    ),
                    if (_selectedFile != null)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(
                          _selectedFile!.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFFABB2BF)),
                        ),
                      ),
                  ],
                ),
                if (_selectedFile == null) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'No file selected yet.',
                    style: TextStyle(color: Color(0xFFABB2BF)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isTraining ? null : _retrainModel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC778DD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isTraining
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.autorenew_rounded),
              label: Text(
                _isTraining ? 'Training model...' : 'Train model',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _ResultPanel(
            title: 'Retraining status',
            message: _trainMessage,
            isError: _trainingIsError,
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Text(
              'CropPulse',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Container(width: 120, height: 2, color: const Color(0xFFC778DD)),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Crop production prediction and model retraining in one place.',
          style: TextStyle(fontSize: 16, color: Color(0xFFABB2BF), height: 1.7),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3040),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC778DD).withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFC778DD), thickness: 0.7),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFABB2BF),
              height: 1.7,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String title;
  final String message;
  final bool isError;

  const _ResultPanel({
    required this.title,
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isError
        ? Colors.redAccent.withOpacity(0.7)
        : const Color(0xFFC778DD).withOpacity(0.75);

    final bgColor = isError ? const Color(0xFF3A2430) : const Color(0xFF222836);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: isError ? Colors.red[200] : const Color(0xFFABB2BF),
              height: 1.7,
              fontSize: 14.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC778DD).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF2A3040),
      ),
      child: const Text(
        'Powered by the deployed Crop Production Prediction API.',
        style: TextStyle(color: Color(0xFFABB2BF), fontSize: 14),
      ),
    );
  }
}

class _LoadingOverlayCard extends StatelessWidget {
  const _LoadingOverlayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3040),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC778DD).withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFC778DD), strokeWidth: 3),
          SizedBox(height: 18),
          Text(
            'Training the model...',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while the uploaded dataset is being processed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFABB2BF), height: 1.6),
          ),
        ],
      ),
    );
  }
}
