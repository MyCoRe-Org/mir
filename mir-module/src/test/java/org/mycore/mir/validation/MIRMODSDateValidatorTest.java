package org.mycore.mir.validation;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

class MIRMODSDateValidatorTest {

    @ParameterizedTest
    @ValueSource(strings = {
        "0000",
        "9999",
        "2024-02",
        "2024-02-29",
        "2024-02-29T23:59Z",
        "2024-02-29T23:59+01:30",
        "2024-02-29T23:59-05:00",
        "2024-02-29T23:59:58Z",
        "2024-02-29T23:59:58+01:30",
    })
    void validatesW3CDTF(String value) {
        assertTrue(MIRMODSDateValidator.validateW3CDTF(value));
    }

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {
        " 2024",
        "2024 ",
        "２０２４",
        "+010000",
        "-0001",
        "202402",
        "2024-2",
        "2024-00",
        "2023-02-29",
        "2024-02-30",
        "2024-02-29T23Z",
        "2024-02-29T23:59",
        "2024-02-29T23:59:58",
        "2024-02-29T23:59:58.1Z",
        "2024-02-29T23:59:60Z",
        "2024-02-29T24:00Z",
        "2024-02-29T23:60Z",
        "2024-02-29T23:59+01",
        "2024-02-29T23:59+0130",
        "2024-02-29T23:59+24:00",
        "2024-02-29t23:59z",
        "2024/2025",
    })
    void rejectsInvalidW3CDTF(String value) {
        assertFalse(MIRMODSDateValidator.validateW3CDTF(value));
    }

    @ParameterizedTest
    @ValueSource(strings = {
        "19",
        "198",
        "0000",
        "9999",
        "2024-02",
        "00000229",
        "20240229",
        "2024060",
        "2024366",
        "2020W53",
        "2020W531",
        "20240229T23",
        "20240229T2359",
        "20240229T235958",
        "20240229T235958Z",
        "20240229T235958+01",
        "20240229T235958-0530",
        "2024060T2359Z",
        "2020W531T235958+01",
        "1985/19860412",
        "2024-02/20241231",
        "2020W53/2021001",
        "2024/2023",
        "20240229T235958Z/2024060T2359+01",
    })
    void validatesMODSISO8601(String value) {
        assertTrue(MIRMODSDateValidator.validateISO8601(value));
    }

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {
        " 2024",
        "2024 ",
        "２０２４",
        "1",
        "20240",
        "+010000",
        "-0001",
        "202401",
        "2024-00",
        "2024-13",
        "20230229",
        "2023366",
        "2021W53",
        "2021W531",
        "2020W530",
        "2020W538",
        "2024-02-29",
        "2024-060",
        "2024-W09-4",
        "2024T23",
        "2024-02T23",
        "2020W53T23",
        "20240229T",
        "20240229T24",
        "20240229T2360",
        "20240229T235960Z",
        "20240229T235958.1Z",
        "20240229T23:59Z",
        "20240229T235958+01:00",
        "20240229T235958+24",
        "20240229T235958+2360",
        "20240229t235958z",
        "T235958Z",
        "P1Y",
        "2024/P1Y",
        "R12/2024/2025",
        "/2024",
        "2024/",
        "2024//2025",
        "2024/2025/2026",
        "2024/20230229",
    })
    void rejectsInvalidMODSISO8601(String value) {
        assertFalse(MIRMODSDateValidator.validateISO8601(value));
    }
}
