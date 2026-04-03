import 'package:flutter/material.dart';
import 'models/unggahan.dart';
import 'search_overlay_page.dart';
import 'unggahan_detail_page.dart';

class PlaceDetailPage extends StatefulWidget {
  final PlaceSummary place;

  const PlaceDetailPage({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.place.placeName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4AA5A6),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF4AA5A6),
          labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 13),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Ulasan"),
            Tab(text: "Unggahan"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUlasanTab(),
          _buildUnggahanTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionItem(Icons.directions, "Directions", true),
            _buildActionItem(Icons.bookmark_border, "Save", false),
            _buildActionItem(Icons.share_outlined, "Share", false),
            _buildActionItem(Icons.public, "Website", false),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, bool isPrimary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF0F9D58) : Colors.transparent, // Google Maps green or transparent
            shape: BoxShape.circle,
            border: isPrimary ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : const Color(0xFF4AA5A6),
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            color: isPrimary ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final representativeUnggahan = widget.place.unggahans.first;
    final String address = representativeUnggahan.address.isNotEmpty 
        ? representativeUnggahan.address 
        : 'Alamat tidak tersedia';
    final String budget = representativeUnggahan.budget.isNotEmpty 
        ? representativeUnggahan.budget 
        : '-';

    // Extract all images across all reviews
    final List<String> allImages = widget.place.unggahans.expand((u) => u.imagePaths).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 0),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            widget.place.placeName,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        _buildListTile(Icons.location_on_outlined, address),
        _buildListTile(Icons.access_time, "Buka ⋅ Tutup pukul 22.00 (Mock)"),
        _buildListTile(Icons.public, "instagram.com"),
        const Divider(height: 24, thickness: 8, color: Color(0xFFF1F3F4)),
        
        // Gallery Section
        if (allImages.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "View the menu & photos",
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _tabController.animateTo(2),
                  child: const Text(
                    "See all",
                    style: TextStyle(fontFamily: 'Inter', color: Color(0xFF4AA5A6), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      allImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        _buildListTile(Icons.payments_outlined, "$budget per person"),
        const Divider(height: 24, thickness: 8, color: Color(0xFFF1F3F4)),

        // Ratings & Reviews Summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Review summary",
                style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        widget.place.averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 48, fontWeight: FontWeight.bold, height: 1.0),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.place.averageRating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "(${widget.place.postCount})",
                        style: TextStyle(fontFamily: 'Inter', color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Fake progress bars
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, 0.8),
                        _buildRatingBar(4, 0.15),
                        _buildRatingBar(3, 0.05),
                        _buildRatingBar(2, 0.0),
                        _buildRatingBar(1, 0.0),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Show up to 2 recent reviews
        if (widget.place.unggahans.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                ...widget.place.unggahans.take(2).map((u) => _buildReviewCard(u)),
                TextButton(
                  onPressed: () => _tabController.animateTo(1), // Go to Ulasan tab
                  child: const Text("More reviews", style: TextStyle(color: Color(0xFF4AA5A6), fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildListTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4AA5A6), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double fill) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(star.toString(), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: fill,
              backgroundColor: Colors.grey.shade300,
              color: Colors.orange,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUlasanTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      itemCount: widget.place.unggahans.length,
      itemBuilder: (context, index) {
        final unggahan = widget.place.unggahans[index];
        return Column(
          children: [
            _buildReviewCard(unggahan),
            if (index < widget.place.unggahans.length - 1)
              const Divider(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(Unggahan unggahan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF4AA5A6),
                child: Text(
                  unggahan.userAvatar ?? unggahan.userName[0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unggahan.userName, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                  Text(unggahan.usernameHandle, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < unggahan.rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 14,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text("a month ago", style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            unggahan.review,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.4),
          ),
          if (unggahan.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: unggahan.imagePaths.length,
                itemBuilder: (ctx, i) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade300,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        unggahan.imagePaths[i],
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnggahanTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: widget.place.unggahans.length,
      itemBuilder: (context, index) {
        final unggahan = widget.place.unggahans[index];
        
        final imageUrl = unggahan.imagePaths.isNotEmpty ? unggahan.imagePaths.first : '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UnggahanDetailPage(unggahan: unggahan)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (imageUrl.isEmpty)
                  const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                // Overlay gradient for text readability
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF4AA5A6),
                        child: Text(
                          unggahan.userAvatar ?? unggahan.userName[0],
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          unggahan.userName,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          unggahan.rating.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
