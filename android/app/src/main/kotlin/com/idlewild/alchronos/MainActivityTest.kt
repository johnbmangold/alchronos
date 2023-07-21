package com.idlewild.alchronos

import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Rule
import org.junit.runner.RunWith


@RunWith(FlutterTestRunner::class)
class MainActivityTest {
    @JvmField
    @Rule
    var rule = ActivityTestRule(MainActivity::class.java, true, false)
}