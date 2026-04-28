import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/home/panti_detail_screen.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kSalmon = Color(0xFFEBB9B1);

// ─── Main Screen ──────────────────────────────────────────────────────────────

class BeritaDetailPanti extends StatefulWidget {
  final int beritaId;
  final int? userId;
  final int? pantiId;
  final int? viewerPantiId;
  final VoidCallback? onGoToOwnProfile;
  final String title;
  final String? thumbnail;
  final String? pantiProfilePicture;
  final String date;
  final String authorName;
  final String pantiName;
  final String body;
  final int upvoteCount;
  final int downvoteCount;

  const BeritaDetailPanti({
    super.key,
    required this.beritaId,
    required this.userId,
    this.pantiId,
    this.viewerPantiId,
    this.onGoToOwnProfile,
    required this.title,
    required this.thumbnail,
    this.pantiProfilePicture,
    required this.date,
    required this.authorName,
    required this.pantiName,
    required this.body,
    required this.upvoteCount,
    required this.downvoteCount,
  });

  @override
  State<BeritaDetailPanti> createState() => _BeritaDetailPantiState();
}

class _BeritaDetailPantiState extends State<BeritaDetailPanti> {
  late int _upvotes;
  late int _downvotes;
  bool _hasUpvoted = false;
  bool _hasDownvoted = false;
  bool _voting = false;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _upvotes = widget.upvoteCount;
    _downvotes = widget.downvoteCount;
    _loadVoteState();
  }

  Future<void> _loadVoteState() async {
    if (widget.userId == null) return;
    try {
      final result = await ContentApi().fetchUserVote(widget.beritaId, widget.userId!);
      if (!mounted) return;
      final userVote = result['user_vote'] as String?;
      setState(() {
        _upvotes   = result['upvote_count']   ?? _upvotes;
        _downvotes = result['downvote_count'] ?? _downvotes;
        _hasUpvoted   = userVote == 'up';
        _hasDownvoted = userVote == 'down';
      });
    } catch (_) {}
  }

  Future<void> _vote(String voteType) async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk memberi vote')),
      );
      return;
    }
    if (_voting) return;
    setState(() => _voting = true);

    try {
      final result = await ContentApi().voteBerita(
        widget.beritaId,
        widget.userId!,
        voteType,
      );
      if (!mounted) return;
      final userVote = result['user_vote'] as String?;
      setState(() {
        _upvotes      = result['upvote_count']   ?? _upvotes;
        _downvotes    = result['downvote_count'] ?? _downvotes;
        _hasUpvoted   = userVote == 'up';
        _hasDownvoted = userVote == 'down';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _voting = false);
    }
  }

  void _onUpvote() => _vote('up');
  void _onDownvote() => _vote('down');

  Future<void> _onLihatProfil() async {
    if (widget.pantiId == null) return;

    // If the viewer is the owner of this berita, pop back and switch to profile tab
    if (widget.viewerPantiId != null && widget.viewerPantiId == widget.pantiId) {
      Navigator.pop(context);
      widget.onGoToOwnProfile?.call();
      return;
    }

    setState(() => _loadingProfile = true);
    try {
      final api = ProfileApi();
      final results = await Future.wait([
        api.fetchPantiProfile(widget.pantiId!),
        api.fetchPantiMedia(widget.pantiId!),
      ]);
      if (!mounted) return;
      final profile = results[0] as PantiProfileModel;
      final media = results[1] as List<PantiMediaModel>;
      final mediaUrls = media
          .where((m) => m.file != null && m.file!.isNotEmpty)
          .map((m) => m.file!)
          .toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantiDetailScreen(
            pantiId: widget.pantiId,
            namaPanti: profile.namaPanti,
            username: '@${profile.username}',
            nomorPanti: profile.nomorPanti,
            alamatPanti: profile.alamatPanti,
            description: profile.description,
            profilePicture: profile.profilePicture,
            terkumpul: profile.formattedTotalTerkumpul,
            userId: widget.userId,
            showNavBar: false,
            mediaUrls: mediaUrls,
            isPantiViewer: true,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat profil panti')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Berita',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Article Title ────────────────────────────────────────────
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // ── Featured Image ───────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: widget.thumbnail != null
                    ? Image.network(
                        widget.thumbnail!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                color: const Color(0xFFE0E0E0),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(kPink),
                                  ),
                                ),
                              ),
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Icon(Icons.broken_image_outlined,
                              color: Colors.grey, size: 40),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(Icons.newspaper_rounded,
                            color: Colors.grey, size: 40),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Body Text ────────────────────────────────────────────────
            Text(
              widget.body,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.65,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            // ── Author Card + Voting ──────────────────────────────────────
            _buildAuthorVoting(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ─── Author Card + Voting ─────────────────────────────────────────────────

  Widget _buildAuthorVoting() {
    return Column(
      children: [
        // Author card
        GestureDetector(
          onTap: _loadingProfile ? null : _onLihatProfil,
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kSalmon,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.grey[300],
                  image: widget.pantiProfilePicture != null
                      ? DecorationImage(
                          image: NetworkImage(widget.pantiProfilePicture!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.pantiProfilePicture == null
                    ? const Icon(Icons.home_work_rounded, color: Colors.white, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pantiName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.authorName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // Date
              Text(
                widget.date,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        ),
        const SizedBox(height: 10),

        // Lihat Profil button
        if (widget.pantiId != null)
          Center(
            child: SizedBox(
              width: 200,
              height: 46,
              child: ElevatedButton(
                onPressed: _loadingProfile ? null : _onLihatProfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8848A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _loadingProfile
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Lihat Profil',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        const SizedBox(height: 10),

        // Voting row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Downvote
            _VoteButton(
              icon: _hasDownvoted ? Icons.arrow_downward_rounded : Icons.arrow_downward_outlined,
              count: _downvotes,
              active: _hasDownvoted,
              activeColor: kPink,
              onTap: _onDownvote,
            ),
            const SizedBox(width: 16),
            // Upvote
            _VoteButton(
              icon: _hasUpvoted ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
              count: _upvotes,
              active: _hasUpvoted,
              activeColor: kPink,
              onTap: _onUpvote,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Vote Button ──────────────────────────────────────────────────────────────

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF888888);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(icon, key: ValueKey(active), color: color, size: 22),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

