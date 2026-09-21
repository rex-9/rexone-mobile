package com.rex9.rexone;

import org.junit.Rule;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.PatrolTestRule;
import pl.leancode.patrol.PatrolTestRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Rule
    public PatrolTestRule<MainActivity> rule = new PatrolTestRule<>(MainActivity.class);

    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolTestRunner.setUp(MainActivity.class);
        return PatrolTestRunner.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @org.junit.Test
    public void run() {
        rule.run(dartTestName);
    }
}
