import 'package:flutter/material.dart';

import '../../../Components/provider.dart';

class portsContainer extends StatelessWidget {
  const portsContainer({
    super.key,
    required this.screenDataProvider,
    required this.Container_One_Name,
    required this.port_ChannelOne_isConnected,
    required this.port_ChannelOne_Power,
    required this.Container_Two_Name,
    required this.port_ChannelTwo_isConnected,
    required this.port_ChannelTwo_Power,
    required this.main_Container_Name,
  });

  final ScreenDataProvider screenDataProvider;
  final String Container_One_Name;
  final bool port_ChannelOne_isConnected;
  final double port_ChannelOne_Power;
  final String Container_Two_Name;
  final bool port_ChannelTwo_isConnected;
  final double port_ChannelTwo_Power;
  final String main_Container_Name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 5,
        ),
        Text(
          main_Container_Name,
          style: TextStyle(
            color: screenDataProvider.isThemeDark
                ? const Color(0xBBffffff)
                : const Color(0x99000000),
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: screenDataProvider.isThemeDark
                      ? const Color(0x65000000)
                      : const Color(0x44000000),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      15,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 5,
                    right: 15,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Container_One_Name,
                                  style: TextStyle(
                                    color: screenDataProvider.isThemeDark
                                        ? const Color(0xccffffff)
                                        : const Color(0xaa000000),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 15,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                        30,
                                      ),
                                    ),
                                    color: port_ChannelOne_isConnected
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      port_ChannelOne_isConnected
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Power: ',
                                  style: TextStyle(
                                    color: screenDataProvider.isThemeDark
                                        ? const Color(0x99FFFFFF)
                                        : const Color(0x99000000),
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$port_ChannelOne_Power',
                                  style: TextStyle(
                                    color: screenDataProvider.isThemeDark
                                        ? const Color(0xccFFFFFF)
                                        : const Color(0x99000000),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Not Connected',
                              style: TextStyle(
                                color: screenDataProvider.isThemeDark
                                    ? const Color(0x66FFFFFF)
                                    : const Color(0x99000000),
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: screenDataProvider.isThemeDark
                      ? const Color(0x65000000)
                      : const Color(0x44000000),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      15,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 5,
                    right: 15,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Container_Two_Name,
                                  style: TextStyle(
                                    color: screenDataProvider.isThemeDark
                                        ? const Color(0xccffffff)
                                        : const Color(0xaa000000),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 15,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                        40,
                                      ),
                                    ),
                                    color: port_ChannelTwo_isConnected
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      port_ChannelTwo_isConnected
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Power: ',
                                  style: TextStyle(
                                    color: screenDataProvider.isThemeDark
                                        ? const Color(0x99FFFFFF)
                                        : const Color(0x99000000),
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$port_ChannelTwo_Power',
                                  style: TextStyle(
                                    color: screenDataProvider.isThemeDark
                                        ? const Color(0xccFFFFFF)
                                        : const Color(0x99000000),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Not Connected',
                              style: TextStyle(
                                color: screenDataProvider.isThemeDark
                                    ? const Color(0x66FFFFFF)
                                    : const Color(0x99000000),
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ],
    );
  }
}
