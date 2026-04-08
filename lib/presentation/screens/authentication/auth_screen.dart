import 'package:bloc_clean_architecture/data/models/auth/user_model.dart';
import 'package:bloc_clean_architecture/presentation/widgets/loading_widget.dart';
import 'package:bloc_clean_architecture/presentation/widgets/primary_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/navigation_service.dart';
import '../../routes/route_names.dart';
import '../../utils/constraints.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_form.dart';
import '/dependency_injection_packages.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_text.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late LoginBloc loginBloc;


  @override
  void initState() {
    loginBloc = context.read<LoginBloc>()
      ..add(LoginInfoAddEvent((e)=>e.userInfo?.copyWith(isShow: true)??UserModel()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: CustomText(text: 'Login'),automaticallyImplyLeading: false,),
      body: BlocConsumer<LoginBloc, UserModel>(
        listener: (context,login){
          final state = login.loginState;

          if(state is LoginError){
            NavigationService.errorSnackBar(context, state.message);
          }else if(state is LoginLoaded){
            NavigationService.navigateToAndClearStack(RouteNames.homeScreen);
          }
        },
        builder: (context, state) {
          final loginState = state.loginState;
          return Padding(
            padding: Utils.symmetric(h: 14.0),
            child: Column(
              children: [
                CustomText(text: 'Login Now',fontSize: 20.0,fontWeight: FontWeight.w600),
                CustomForm(
                    label: 'Email Address',
                    child: TextFormField(
                      initialValue: state.userInfo?.email,
                      onChanged:(val)=>  loginBloc.add(LoginInfoAddEvent((info)=>info.copyWith(email: val))),
                      validator: Utils.requiredValidator('Email'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration:  InputDecoration(
                        hintText: 'email here',
                        prefix: Utils.horizontalSpace(textFieldSpace),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    )),
                Utils.verticalSpace(10.0),
                CustomForm(
                    label: 'Password',
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      initialValue: state.userInfo?.phone,
                      onChanged:(val)=>  loginBloc.add(LoginInfoAddEvent((info)=>info.copyWith(phone: val))),
                      obscureText: state.userInfo?.isShow?? false,

                      validator: Utils.requiredValidator('Password'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: 'Password here',
                        prefix: Utils.horizontalSpace(textFieldSpace),
                        suffixIcon: IconButton(
                          onPressed:()=> loginBloc.add(LoginInfoAddEvent((info)=>info.copyWith(isShow: !(state.userInfo?.isShow??false)))),
                          icon: Icon((state.userInfo?.isShow?? false) ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: blackColor),
                        ),
                      ),
                    )),
                Utils.verticalSpace(20.0),
                if(loginState is LoginLoading)...[
                  LoadingWidget(),
                ]else...[

                PrimaryButton(text: 'Login', onPressed: ()=>loginBloc.add(LoginEventSubmit()))
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
