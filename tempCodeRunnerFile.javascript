Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Search User",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyTheme.textColor, fontSize: 18),
                    ),
                    Expanded(
                      child: Center(
                        child: IconButton(
                          onPressed: () async => await getAllUsers(),
                          icon: Icon(
                            Icons.refresh,
                            color: MyTheme.accent,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )



              InputDecoration(
                  labelText: 'Reason',
                  labelStyle: TextStyle(color: MyTheme.textColor),
                  alignLabelWithHint: true,
                ),