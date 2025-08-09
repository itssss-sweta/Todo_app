import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/constants/app_colors.dart';
import 'package:todo_app/data/models/todo_model.dart' as model;
import 'package:todo_app/presentation/blocs/todo_bloc.dart';
import 'package:todo_app/presentation/blocs/todo_event.dart';
import 'package:todo_app/presentation/widgets/add_todo_sheet.dart';
import 'package:todo_app/presentation/widgets/todo_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      context.read<TodoBloc>().add(FetchTodos(query: _searchController.text));
    });
    context.read<TodoBloc>().add(FetchTodos(query: ''));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddEditBottomSheet({model.Todo? todo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: AddEditTodoBottomSheet(
          todo: todo != null
              ? {
                  'id': todo.id,
                  'title': todo.title,
                  'description': todo.description,
                  'isCompleted': todo.isCompleted,
                  'deadline': todo.deadline,
                  'createdAt': todo.createdAt,
                }
              : null,
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Todo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this todo? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              context.read<TodoBloc>().add(DeleteTodo(id));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Todo App',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                ],
              ),
              backgroundColor: AppColors.primary,
              expandedHeight: 140.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 90.0, 20.0, 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search your todos...',
                          hintStyle: TextStyle(
                            color:
                                AppColors.textSecondaryLight.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color:
                                AppColors.textSecondaryLight.withOpacity(0.7),
                            size: 20,
                          ),
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 16.0,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.textPrimaryLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pending_actions,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text('Pending'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text('Completed'),
                          ],
                        ),
                      ),
                    ],
                    indicator: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    dividerColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TodoListView(
                    isCompleted: false,
                    isLoading: _isLoading,
                    searchQuery: _searchController.text,
                    onEdit: (todo) => _showAddEditBottomSheet(todo: todo),
                    onDelete: _showDeleteDialog,
                  ),
                  TodoListView(
                    isCompleted: true,
                    isLoading: _isLoading,
                    searchQuery: _searchController.text,
                    onEdit: (todo) => _showAddEditBottomSheet(todo: todo),
                    onDelete: _showDeleteDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddEditBottomSheet(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              'Add Todo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final currentHeight = maxExtent - shrinkOffset;

    final effectiveHeight = currentHeight.clamp(minExtent, maxExtent);

    return SizedBox(
      height: effectiveHeight,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: overlapsContent ? 4.0 : 0.0,
        child: tabBar,
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 66;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
