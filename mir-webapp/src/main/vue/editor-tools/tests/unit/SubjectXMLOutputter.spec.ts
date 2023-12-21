import {
    Genre,
    Geographic,
    HierarchicalGeographic,
    MODS_NAMESPACE,
    Name,
    Temporal,
    TitleInfo,
    Topic
} from "@/api/Subject";
import {
    outputGenre,
    outputGeographic,
    outputName,
    outputTemporal,
    outputTitleInfo,
    outputTopic
} from "@/api/SubjectXMLOutputter";


describe('SubjectXMLOutputter', () => {

    test('outputTopic', () => {
        const modsTopicExamples: Array<Topic> = [
            {
                "type": "Topic",
                "text": "Transformation",
                "authority": "gnd",
                "valueURI": "http://d-nb.info/gnd/4451062-7"
            },
            {
                "type": "Topic",
                "text": "Learning disabilities",
                "authority": "lcsh",
                "valueURI": "http://id.loc.gov/authorities/subjects/sh85075538"
            },
            {"type": "Topic", "text": "Cats", "valueURI": "http://id.loc.gov/authorities/childrensSubjects/sj96004989"},
            {"type": "Topic", "text": "Career Exploration", "authority": "ericd"},
            {"type": "Topic", "text": "Bluegrass music"}
        ];


        const modsTopicAuthorities = ["gnd", "lcsh", null, "ericd", null];

        const modsTopicContent = ["Transformation", "Learning disabilities", "Cats", "Career Exploration",
            "Bluegrass music"];

        const modsTopicValueURIs = ["http://d-nb.info/gnd/4451062-7",
            "http://id.loc.gov/authorities/subjects/sh85075538",
            "http://id.loc.gov/authorities/childrensSubjects/sj96004989", null, null];

        for (const modsTopicExampleIndex in modsTopicExamples) {
            const modsTopicExample = modsTopicExamples[modsTopicExampleIndex];
            const result = outputTopic(modsTopicExample);


            expect(result.tagName).toBe("mods:topic");
            expect(result.textContent).toBe(modsTopicContent[modsTopicExampleIndex]);
            expect(result.getAttribute("authority")).toBe(modsTopicAuthorities[modsTopicExampleIndex]);
            expect(result.getAttribute("valueURI")).toBe(modsTopicValueURIs[modsTopicExampleIndex]);
        }
    });

    test('outputGeographic', () => {
        const modsGeographicExamples: Array<Geographic> = [
            {"type": "Geographic", "text": "United States"},
            {
                "type": "Geographic",
                "text": "Novosibirsk",
                "authority": "geonames",
                "valueURI": "http://www.geonames.org/1496745"
            },
            {
                "type": "Geographic",
                "text": " Mississippi",
                "authority": "naf",
                "valueURI": "http://id.loc.gov/authorities/names/n79138969"
            },
        ];

        const modsGeographicContent = ["United States", "Novosibirsk", " Mississippi"];
        const modsGeographicAuthorities = [null, "geonames", "naf"];
        const modsGeographicValueURIs = [null, "http://www.geonames.org/1496745", "http://id.loc.gov/authorities/names/n79138969"];


        for (const modsGeographicExampleIndex in modsGeographicExamples) {
            const modsGeographicExample = modsGeographicExamples[modsGeographicExampleIndex];
            const result = outputGeographic(modsGeographicExample);

            expect(result.tagName).toBe("mods:geographic");
            expect(result.textContent).toBe(modsGeographicContent[modsGeographicExampleIndex]);
            expect(result.getAttribute("authority")).toBe(modsGeographicAuthorities[modsGeographicExampleIndex]);
            expect(result.getAttribute("valueURI")).toBe(modsGeographicValueURIs[modsGeographicExampleIndex]);
        }

    });


    test('outputTemporal', () => {
        const modsTemporalExamples: Array<Temporal> = [
            {"type": "Temporal", "text": "20th century"},
            {
                "type": "Temporal",
                "text": "19th century",
                "valueURI": "http://id.loc.gov/authorities/subjects/sh2002012475"
            },
            {"type": "Temporal", "text": "2001-09-11", "point": "start", "calendar": "julian", "encoding": "w3cdtf"},
            {"type": "Temporal", "text": "2003-03-19", "point": "end", "calendar": "julian", "encoding": "w3cdtf"}];

        const modsTemporalContent = ["20th century", "19th century", "2001-09-11", "2003-03-19"];
        const modsTemporalValueURIs = [null, "http://id.loc.gov/authorities/subjects/sh2002012475", null, null];
        const modsTemporalPoints = [null, null, "start", "end"];
        const modsTemporalCalendars = [null, null, "julian", "julian"];
        const modsTemporalEncodings = [null, null, "w3cdtf", "w3cdtf"];

        for (const modsTemporalExampleIndex in modsTemporalExamples) {
            const modsTemporalExample = modsTemporalExamples[modsTemporalExampleIndex];
            const result = outputTemporal(modsTemporalExample);

            expect(result.tagName).toBe("mods:temporal");
            expect(result.textContent).toBe(modsTemporalContent[modsTemporalExampleIndex]);
            expect(result.getAttribute("valueURI")).toBe(modsTemporalValueURIs[modsTemporalExampleIndex]);
            expect(result.getAttribute("point")).toBe(modsTemporalPoints[modsTemporalExampleIndex]);
            expect(result.getAttribute("calendar")).toBe(modsTemporalCalendars[modsTemporalExampleIndex]);
            expect(result.getAttribute("encoding")).toBe(modsTemporalEncodings[modsTemporalExampleIndex]);
        }
    });


    test('outputTitleInfo', () => {
        const modsTitleInfoExamples: Array<TitleInfo> = [
            {
                "type": "TitleInfo",
                "title": ["Science and public affairs"],
                "subTitle": [],
                "partNumber": [],
                "partName": [],
                "nonSort": [],
                "titleType": "alternative",
                "displayLabel": "Spine title"
            },
            {
                "type": "TitleInfo",
                "title": ["\"wintermind\""],
                "subTitle": ["William Bonk and American letters"],
                "partNumber": [],
                "partName": [],
                "nonSort": ["The "]
            },
            {
                "type": "TitleInfo",
                "title": ["Olympics"],
                "subTitle": ["a history"],
                "partNumber": ["Part 1"],
                "partName": ["Ancient"],
                "nonSort": ["The "]
            },
            {
                "type": "TitleInfo",
                "title": ["homme qui voulut être roi"],
                "subTitle": [],
                "partNumber": [],
                "partName": [],
                "nonSort": ["L'"],
                "titleType": "translated",
                "lang": "fr"
            }
        ];

        const modsTitleInfoTitles = [["Science and public affairs"], ["\"wintermind\""], ["Olympics"], ["homme qui voulut être roi"]];
        const modsTitleInfoSubTitles = [[], ["William Bonk and American letters"], ["a history"], []];
        const modsTitleInfoPartNumbers = [[], [], ["Part 1"], []];
        const modsTitleInfoPartNames = [[], [], ["Ancient"], []];
        const modsTitleInfoNonSorts = [[], ["The "], ["The "], ["L'"]];
        const modsTitleInfoTitleTypes = ["alternative", null, null, "translated"];
        const modsTitleInfoDisplayLabels = ["Spine title", null, null, null];
        const modsTitleInfoLangs = [null, null, null, "fr"];

        expect(modsTitleInfoExamples.length).toBe(modsTitleInfoTitles.length);

        for (const modsTitleInfoExampleIndex in modsTitleInfoExamples) {
            const modsTitleInfoExample = modsTitleInfoExamples[modsTitleInfoExampleIndex];
            const result = outputTitleInfo(modsTitleInfoExample);

            expect(result.tagName).toBe("mods:titleInfo");
            expect(result.getAttribute("type")).toBe(modsTitleInfoTitleTypes[modsTitleInfoExampleIndex]);
            expect(result.getAttribute("displayLabel")).toBe(modsTitleInfoDisplayLabels[modsTitleInfoExampleIndex]);
            expect(result.getAttributeNS("http://www.w3.org/XML/1998/namespace", "lang")).toBe(modsTitleInfoLangs[modsTitleInfoExampleIndex]);

            if (modsTitleInfoTitles[modsTitleInfoExampleIndex].length > 0) {
                expect(result.getElementsByTagName("mods:title")[0].textContent).toBe(modsTitleInfoTitles[modsTitleInfoExampleIndex][0]);
            }

            if (modsTitleInfoSubTitles[modsTitleInfoExampleIndex].length > 0) {
                expect(result.getElementsByTagName("mods:subTitle")[0].textContent).toBe(modsTitleInfoSubTitles[modsTitleInfoExampleIndex][0]);
            }

            if (modsTitleInfoPartNumbers[modsTitleInfoExampleIndex].length > 0) {
                expect(result.getElementsByTagName("mods:partNumber")[0].textContent).toBe(modsTitleInfoPartNumbers[modsTitleInfoExampleIndex][0]);
            }

            if (modsTitleInfoPartNames[modsTitleInfoExampleIndex].length > 0) {
                expect(result.getElementsByTagName("mods:partName")[0].textContent).toBe(modsTitleInfoPartNames[modsTitleInfoExampleIndex][0]);
            }

            if (modsTitleInfoNonSorts[modsTitleInfoExampleIndex].length > 0) {
                expect(result.getElementsByTagName("mods:nonSort")[0].textContent).toBe(modsTitleInfoNonSorts[modsTitleInfoExampleIndex][0]);
            }
        }
    });

    test('outputName', () => {
        const modsNameExamples: Array<Name> = [
            {
                "type": "Name",
                "nameParts": [{"text": "Arthur Mitchell"}],
                "role": [],
                "affiliation": [],
                "nameIdentifier": [{"text": "http://www.wikidata.org/entity/Q3753500"}],
                "nameType": "personal"
            },
            {
                "type": "Name",
                "nameParts": [{"text": "Arthur Mitchell"}],
                "role": [],
                "affiliation": [],
                "nameIdentifier": [{"text": "http://www.wikidata.org/entity/Q3753500"}],
                "nameType": "personal"
            },
            {
                "type": "Name",
                "displayForm": "Friedrich-Loeffler-Institut",
                "nameParts": [],
                "role": [{"text": "isb", "type": "code", "authority": "marcrelator"}],
                "affiliation": [],
                "nameIdentifier": [{"type": "gnd", "text": "10094896-0"}],
                "nameType": "corporate"
            }
        ];

        const modsNameNameParts = [["Arthur Mitchell"], ["Arthur Mitchell"], []];
        const modsNameDisplayForms = [null, null, "Friedrich-Loeffler-Institut"];
        const modsNameRoles = [[], [], [{"text": "isb", "type": "code", "authority": "marcrelator"}]];
        const modsNameAffiliations = [[], [], []];
        const modsNameNameIdentifiers = [[{"text": "http://www.wikidata.org/entity/Q3753500"}], [{"text": "http://www.wikidata.org/entity/Q3753500"}], [{
            "type": "gnd",
            "text": "10094896-0"
        }]];
        const modsNameNameTypes = ["personal", "personal", "corporate"];

        expect(modsNameExamples.length).toBe(modsNameNameParts.length);

        for (const modsNameExampleIndex in modsNameExamples) {
            const modsNameExample = modsNameExamples[modsNameExampleIndex];
            const result = outputName(modsNameExample);

            expect(result.tagName).toBe("mods:name");
            expect(result.getAttribute("type")).toBe(modsNameNameTypes[modsNameExampleIndex]);
            if (modsNameDisplayForms[modsNameExampleIndex] !== null) {
                expect(result.getElementsByTagNameNS(MODS_NAMESPACE, "displayForm")[0].textContent).toBe(modsNameDisplayForms[modsNameExampleIndex]);
            }

            if (modsNameNameParts[modsNameExampleIndex].length > 0) {
                expect(result.getElementsByTagNameNS(MODS_NAMESPACE, "namePart")[0].textContent).toBe(modsNameNameParts[modsNameExampleIndex][0]);
            }

            if (modsNameRoles[modsNameExampleIndex].length > 0) {
                let roleElement = result.getElementsByTagNameNS(MODS_NAMESPACE, "role")[0];
                let roleTermElement = roleElement.getElementsByTagNameNS(MODS_NAMESPACE, "roleTerm")[0];
                expect(roleTermElement.textContent).toBe(modsNameRoles[modsNameExampleIndex][0].text);
                expect(roleTermElement.getAttribute("type")).toBe(modsNameRoles[modsNameExampleIndex][0].type);
                expect(roleTermElement.getAttribute("authority")).toBe(modsNameRoles[modsNameExampleIndex][0].authority);
            }

            if (modsNameAffiliations[modsNameExampleIndex].length > 0) {
                expect(result.getElementsByTagNameNS(MODS_NAMESPACE, "affiliation")[0].textContent).toBe(modsNameAffiliations[modsNameExampleIndex][0]);
            }

            if (modsNameNameIdentifiers[modsNameExampleIndex].length > 0) {
                expect(result.getElementsByTagNameNS(MODS_NAMESPACE, "nameIdentifier")[0].textContent).toBe(modsNameNameIdentifiers[modsNameExampleIndex][0].text);
            }
        }
    });

    test('outputGenre', () => {
        const modsGenreExamples: Array<Genre> = [
            {
                type: 'Genre',
                text: 'Exhibition catalogs',
                authority: undefined,
                authorityURI: undefined,
                valueURI: 'http://id.loc.gov/authorities/genreForms/gf2014026098',
                genreType: undefined
            },
            {
                type: 'Genre',
                text: 'Exhibitions',
                authority: undefined,
                authorityURI: undefined,
                valueURI: 'http://id.loc.gov/authorities/subjects/sh99001275',
                genreType: undefined
            },
            {
                type: 'Genre',
                text: 'book',
                authority: 'marcgt',
                authorityURI: undefined,
                valueURI: undefined,
                genreType: undefined
            }
        ];

        const modsGenreTexts = ['Exhibition catalogs', 'Exhibitions', 'book'];
        const modsGenreAuthorities = [null, null, 'marcgt'];
        const modsGenreAuthorityURIs = [null, null, null];
        const modsGenreValueURIs = ['http://id.loc.gov/authorities/genreForms/gf2014026098', 'http://id.loc.gov/authorities/subjects/sh99001275', null];
        const modsGenreGenreTypes = [null, null, null];

        expect(modsGenreExamples.length).toBe(modsGenreTexts.length);

        for (const modsGenreExampleIndex in modsGenreExamples) {
            const modsGenreExample = modsGenreExamples[modsGenreExampleIndex];
            const result = outputGenre(modsGenreExample);

            expect(result.tagName).toBe('mods:genre');
            expect(result.textContent).toBe(modsGenreTexts[modsGenreExampleIndex]);
            expect(result.getAttribute('authority')).toBe(modsGenreAuthorities[modsGenreExampleIndex]);
            expect(result.getAttribute('authorityURI')).toBe(modsGenreAuthorityURIs[modsGenreExampleIndex]);
            expect(result.getAttribute('valueURI')).toBe(modsGenreValueURIs[modsGenreExampleIndex]);
            expect(result.getAttribute('type')).toBe(modsGenreGenreTypes[modsGenreExampleIndex]);
        }
    });


    test('outputHierarchicalGeographic', () => {
        const modsHierarchicalGeographicExamples: Array<HierarchicalGeographic> = [
            {
                "type": "HierarchicalGeographic",
                "children": [{"type": "country", "text": "Canada"}, {"type": "city", "text": "Vancouver"}]
            },
            {
                "type": "HierarchicalGeographic",
                "children": [{"type": "country", "text": "United States"}, {
                    "type": "state",
                    "text": "Mississippi"
                }, {"type": "county", "text": "Harrison"}, {"type": "city", "text": "Biloxi"}]
            },
            {
                "type": "HierarchicalGeographic",
                "children": [{"type": "country", "level": 1, "text": "United Kingdom"}, {
                    "type": "country",
                    "level": 2,
                    "text": "England"
                }, {"type": "region", "text": "North West"}, {"type": "county", "text": "Cumbria"}, {
                    "type": "area",
                    "text": "Lake District",
                    "areaType": "national park"
                }]
            },
            {
                "type": "HierarchicalGeographic",
                "children": [{"type": "country", "text": "United States"}, {
                    "type": "state",
                    "text": "Rhode Island"
                }, {"type": "city", "text": "Providence"}, {
                    "type": "citySection",
                    "level": 1,
                    "text": "East Side",
                    "citySectionType": "neighborhood"
                }, {"type": "citySection", "level": 2, "text": "Blackstone", "citySectionType": "neighborhood"}]
            }
        ];

        // TODO: Add tests for outputHierarchicalGeographic



    });

});