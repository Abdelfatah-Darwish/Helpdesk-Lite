import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/workspace_shell.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../domain/entities/ticket.dart';
import '../bloc/ticket_bloc.dart';
import '../bloc/ticket_event.dart';
import '../bloc/ticket_state.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketPriority _selectedPriority = TicketPriority.medium;
  TicketCategory _selectedCategory = TicketCategory.it;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit(String creatorId, String creatorName) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<TicketBloc>().add(
            CreateTicketSubmitted(
              subject: _subjectController.text,
              description: _descriptionController.text,
              priority: _selectedPriority,
              category: _selectedCategory,
              creatorId: creatorId,
              creatorName: creatorName,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const Scaffold();

    final user = authState.user;

    return WorkspaceShell(
      title: 'Submit Support Ticket',
      child: BlocListener<TicketBloc, TicketState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Post local notification
            context.read<NotificationBloc>().add(AddLocalNotification(
                  ticketId: state.allTickets.first.id,
                  message: 'Your ticket "${_subjectController.text}" was submitted successfully.',
                ));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Support ticket created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            
            // Pop back to tickets list
            context.pop();
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ResponsiveLayout(
              mobile: _buildForm(user.id, user.name, double.infinity, isCompact: true),
              tablet: _buildForm(user.id, user.name, 600, isCompact: false),
              desktop: _buildForm(user.id, user.name, 700, isCompact: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(String userId, String userName, double width, {required bool isCompact}) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: EdgeInsets.all(isCompact ? 16 : 32),
      decoration: isCompact
          ? null
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Submit Support Request',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Provide details about your issue. Support staff will respond shortly.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Subject
            CustomTextField(
              label: 'Subject',
              hint: 'Brief summary of the issue (e.g. Email access blocked)',
              controller: _subjectController,
              validator: (v) => Validators.validateRequired(v, 'Subject'),
            ),
            const SizedBox(height: 20),

            // Description
            CustomTextField(
              label: 'Detailed Description',
              hint: 'Please provide full details, error messages, and steps to reproduce...',
              controller: _descriptionController,
              maxLines: 5,
              validator: (v) => Validators.validateRequired(v, 'Description'),
            ),
            const SizedBox(height: 20),

            // Priority and Category selectors
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<TicketCategory>(
                        key: ValueKey(_selectedCategory),
                        initialValue: _selectedCategory,
                        items: TicketCategory.values
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.displayName),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<TicketPriority>(
                        key: ValueKey(_selectedPriority),
                        initialValue: _selectedPriority,
                        items: TicketPriority.values
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.displayName),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPriority = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submission Actions
            BlocBuilder<TicketBloc, TicketState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      label: 'Cancel',
                      onPressed: state.isSubmitting ? null : () => context.pop(),
                      isOutlined: true,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      label: 'Submit Ticket',
                      onPressed: () => _onSubmit(userId, userName),
                      isLoading: state.isSubmitting,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
