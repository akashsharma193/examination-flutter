import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/ranking_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';
import 'package:feather_icons/feather_icons.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ExamRepo _examRepo = ExamRepo();
  final TextEditingController _searchController = TextEditingController();

  List<RankingModel> _rankings = [];
  List<RankingModel> _filteredRankings = [];
  bool _isLoading = true;
  String _batchCode = '';

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRankings() async {
    setState(() {
      _isLoading = true;
    });

    final userBatch = AppLocalStorage.instance.user.batch;

    if (userBatch.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      AppSnackbarWidget.showSnackBar(
        isSuccess: false,
        subTitle: 'Batch code not found',
      );
      return;
    }

    _batchCode = userBatch;

    final result = await _examRepo.getRankings(batchCode: userBatch);

    switch (result) {
      case AppSuccess():
        setState(() {
          _rankings = result.value;
          _filteredRankings = result.value;
          _isLoading = false;
        });
        break;
      case AppFailure():
        setState(() {
          _isLoading = false;
        });
        AppSnackbarWidget.showSnackBar(
          isSuccess: false,
          subTitle: result.errorMessage,
        );
        break;
    }
  }

  void _filterRankings(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRankings = _rankings;
      } else {
        _filteredRankings = _rankings.where((ranking) {
          return ranking.name.toLowerCase().contains(query.toLowerCase()) ||
              ranking.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildRankIcon(int rank) {
    switch (rank) {
      case 1:
        return const Icon(FeatherIcons.award,
            color: Color(0xFFFFD700), size: 24);
      case 2:
        return const Icon(FeatherIcons.award,
            color: Color(0xFFC0C0C0), size: 24);
      case 3:
        return const Icon(FeatherIcons.award,
            color: Color(0xFFCD7F32), size: 24);
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getRankBadgeColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF5038ED);
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5038ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Ranking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF5038ED)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Rankings...',
                    style: TextStyle(
                      color: Color(0xFF5038ED),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : _rankings.isEmpty
              ? const Center(
                  child: Text(
                    'No ranking data found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                FeatherIcons.award,
                                color: Color(0xFF5038ED),
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Leaderboard Rankings',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5038ED),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Students: ${_rankings.length} • Batch: $_batchCode',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            onChanged: _filterRankings,
                            decoration: InputDecoration(
                              hintText: 'Filter by name or email...',
                              prefixIcon: const Icon(
                                FeatherIcons.search,
                                color: Color(0xFF5038ED),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(FeatherIcons.x),
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterRankings('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5038ED),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5038ED),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5038ED),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F0FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFE0D7FF),
                                  ),
                                ),
                                child: Text(
                                  'Showing ${_filteredRankings.length} of ${_rankings.length} students',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5038ED),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredRankings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    FeatherIcons.search,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No students found matching "${_searchController.text}"',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterRankings('');
                                    },
                                    child: const Text(
                                      'Clear filter',
                                      style: TextStyle(
                                        color: Color(0xFF5038ED),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredRankings.length,
                              itemBuilder: (context, index) {
                                final ranking = _filteredRankings[index];
                                final isTopThree = ranking.ranking <= 3;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    gradient: isTopThree
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFF3F0FF),
                                              Colors.white,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          )
                                        : null,
                                    color: isTopThree ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            _buildRankIcon(ranking.ranking),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getRankBadgeColor(
                                                    ranking.ranking),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '#${ranking.ranking}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                ranking.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                ranking.email,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getPercentageColor(
                                                        ranking.percentage)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${ranking.percentage.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  color: _getPercentageColor(
                                                      ranking.percentage),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              'Marks: ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              '${ranking.marks}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF5038ED),
                                              ),
                                            ),
                                            Text(
                                              ' / ${ranking.totalMarks}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
