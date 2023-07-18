import {
    parseCartographics,
    parseGenre,
    parseGeographic,
    parseHierarchicalGeographic,
    parseName,
    parseTemporal,
    parseTitleInfo,
    parseTopic
} from "@/api/SubjectParser";
import {Cartographics, MODS_NAMESPACE, NameIdentifier, RoleTerm} from "@/api/Subject";


describe('SubjectParser', () => {

    test('parseTopic', () => {
        const modsTopicExamples = [
            `<mods:topic xmlns:mods="${MODS_NAMESPACE}" authority="gnd" valueURI="http://d-nb.info/gnd/4451062-7">Transformation</mods:topic>`,
            `<mods:topic xmlns:mods="${MODS_NAMESPACE}" authority="lcsh" valueURI="http://id.loc.gov/authorities/subjects/sh85075538">Learning disabilities</mods:topic>`,
            `<mods:topic xmlns:mods="${MODS_NAMESPACE}" valueURI="http://id.loc.gov/authorities/childrensSubjects/sj96004989">Cats</mods:topic>`,
            `<mods:topic xmlns:mods="${MODS_NAMESPACE}" authority="ericd">Career Exploration</mods:topic>`,
            `<mods:topic xmlns:mods="${MODS_NAMESPACE}">Bluegrass music</mods:topic>`,
        ];

        const modsTopicAuthorities = ["gnd", "lcsh", undefined, "ericd", undefined];
        const modsTopicContent = ["Transformation", "Learning disabilities", "Cats", "Career Exploration", "Bluegrass music"];
        const modsTopicValueURIs = ["http://d-nb.info/gnd/4451062-7", "http://id.loc.gov/authorities/subjects/sh85075538", "http://id.loc.gov/authorities/childrensSubjects/sj96004989", undefined, undefined];

        // TODO: find example of a topic with a authorityURI

        const modsTopicExampleElements = modsTopicExamples.map((modsTopicExample) => {
            // convert the string to an XML element
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(modsTopicExample, "text/xml");
            return xmlDoc.childNodes[0] as Element;

        });

        expect(modsTopicExampleElements.length).toBe(5);
        for (const modsTopicExampleElementIndex in modsTopicExampleElements) {
            const modsTopicExampleElement = modsTopicExampleElements[modsTopicExampleElementIndex];
            const result = parseTopic(modsTopicExampleElement);

            expect(result.type).toBe("Topic");
            expect(result.authority).toBe(modsTopicAuthorities[modsTopicExampleElementIndex]);
            expect(result.valueURI).toBe(modsTopicValueURIs[modsTopicExampleElementIndex]);
            expect(result.text).toBe(modsTopicContent[modsTopicExampleElementIndex]);
        }
    });

    test('parseGeographic', () => {
        const modsGeographicExamples = [
            `<mods:geographic xmlns:mods="${MODS_NAMESPACE}">United States</mods:geographic>`,
            `<mods:geographic xmlns:mods="${MODS_NAMESPACE}" authority="geonames" valueURI="http://www.geonames.org/1496745">Novosibirsk</mods:geographic>`,
            `<mods:geographic xmlns:mods="${MODS_NAMESPACE}" authority="naf" valueURI="http://id.loc.gov/authorities/names/n79138969"> Mississippi</mods:geographic>`,
        ];

        const modsGeographicAuthorities = [undefined, "geonames", "naf"];
        const modsGeographicContent = ["United States", "Novosibirsk", " Mississippi"];
        const modsGeographicValueURIs = [undefined, "http://www.geonames.org/1496745", "http://id.loc.gov/authorities/names/n79138969"];


        // TODO: find example of a geographic with a authorityURI

        const modsGeographicExampleElements = modsGeographicExamples.map((modsGeographicExample) => {
            // convert the string to an XML element
            const parser = new DOMParser();

            const xmlDoc = parser.parseFromString(modsGeographicExample, "text/xml");
            return xmlDoc.childNodes[0] as Element;
        });

        expect(modsGeographicExampleElements.length).toBe(3);
        for (const modsGeographicExampleElementIndex in modsGeographicExampleElements) {
            const modsGeographicExampleElement = modsGeographicExampleElements[modsGeographicExampleElementIndex];
            const result = parseGeographic(modsGeographicExampleElement);

            expect(result.type).toBe("Geographic");
            expect(result.authority).toBe(modsGeographicAuthorities[modsGeographicExampleElementIndex]);
            expect(result.valueURI).toBe(modsGeographicValueURIs[modsGeographicExampleElementIndex]);
            expect(result.text).toBe(modsGeographicContent[modsGeographicExampleElementIndex]);
        }
    });


    test('parseTemporal', () => {
        const modsTemporalExamples = [
            `<mods:temporal xmlns:mods="${MODS_NAMESPACE}">20th century</mods:temporal>`,
            `<mods:temporal xmlns:mods="${MODS_NAMESPACE}" valueURI="http://id.loc.gov/authorities/subjects/sh2002012475">19th century</mods:temporal>`,
            `<mods:temporal xmlns:mods="${MODS_NAMESPACE}" encoding="w3cdtf" point="start" calendar="julian">2001-09-11</mods:temporal>`,
            `<mods:temporal xmlns:mods="${MODS_NAMESPACE}" encoding="w3cdtf" point="end" calendar="julian">2003-03-19</mods:temporal>`,
        ];

        const modsTemporalContent = ["20th century", "19th century", "2001-09-11", "2003-03-19"];
        const modsTemporalValueURIs = [undefined, "http://id.loc.gov/authorities/subjects/sh2002012475", undefined, undefined];
        const modsTemporalEncodings = [undefined, undefined, "w3cdtf", "w3cdtf"];
        const modsTemporalPoints = [undefined, undefined, "start", "end"];
        const modsTemporalCalendars = [undefined, undefined, "julian", "julian"];

        const modsTemporalExampleElements = modsTemporalExamples.map((modsTemporalExample) => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(modsTemporalExample, "text/xml");


            return xmlDoc.childNodes[0] as Element;
        });

        expect(modsTemporalExampleElements.length).toBe(4);
        for (const modsTemporalExampleElementIndex in modsTemporalExampleElements) {
            const modsTemporalExampleElement = modsTemporalExampleElements[modsTemporalExampleElementIndex];
            const result = parseTemporal(modsTemporalExampleElement);

            expect(result.type).toBe("Temporal");
            expect(result.valueURI).toBe(modsTemporalValueURIs[modsTemporalExampleElementIndex]);
            expect(result.text).toBe(modsTemporalContent[modsTemporalExampleElementIndex]);
            expect(result.encoding).toBe(modsTemporalEncodings[modsTemporalExampleElementIndex]);
            expect(result.point).toBe(modsTemporalPoints[modsTemporalExampleElementIndex]);
            expect(result.calendar).toBe(modsTemporalCalendars[modsTemporalExampleElementIndex]);
        }
    });


    test('parseTitleInfo', () => {
        const modsTitleInfoExamples = [
            `<mods:titleInfo xmlns:mods="${MODS_NAMESPACE}" type="alternative" displayLabel="Spine title">
                <mods:title>Science and public affairs</mods:title>
             </mods:titleInfo>`,
            `<mods:titleInfo xmlns:mods="${MODS_NAMESPACE}">
                <mods:nonSort>The </mods:nonSort>
                <mods:title>"wintermind"</mods:title>
                <mods:subTitle>William Bonk and American letters</mods:subTitle>
            </mods:titleInfo>`,
            `<mods:titleInfo xmlns:mods="${MODS_NAMESPACE}">
                <mods:nonSort>The </mods:nonSort>
                <mods:title>Olympics</mods:title>
                <mods:subTitle>a history</mods:subTitle>
                <mods:partNumber>Part 1</mods:partNumber>
                <mods:partName>Ancient</mods:partName>
            </mods:titleInfo>`,
            `<mods:titleInfo xmlns:mods="${MODS_NAMESPACE}" xml:lang="fr" type="translated">
                <mods:nonSort>L'</mods:nonSort>
                <mods:title>homme qui voulut être roi</mods:title>
            </mods:titleInfo>`
        ];

        const modsTitleInfoTypes = ["alternative", undefined, undefined, "translated"];
        const modsTitleInfoDisplayLabels = ["Spine title", undefined, undefined, undefined];
        const modsTitleInfoNonSorts = [[], ["The "], ["The "], ["L'"]];
        const modsTitleInfoTitles = [["Science and public affairs"], ["\"wintermind\""], ["Olympics"], ["homme qui voulut être roi"]];
        const modsTitleInfoSubTitles = [[], ["William Bonk and American letters"], ["a history"], []];
        const modsTitleInfoPartNumbers = [[], [], ["Part 1"], []];
        const modsTitleInfoPartNames = [[], [], ["Ancient"], []];
        const modsTitleInfoLangs = [undefined, undefined, undefined, "fr"];

        const modsTitleInfoExampleElements = modsTitleInfoExamples.map((modsTitleInfoExample) => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(modsTitleInfoExample, "text/xml");

            return xmlDoc.childNodes[0] as Element;
        });

        expect(modsTitleInfoExampleElements.length).toBe(4);

        for (const modsTitleInfoExampleElementIndex in modsTitleInfoExampleElements) {
            const modsTitleInfoExampleElement = modsTitleInfoExampleElements[modsTitleInfoExampleElementIndex];
            const result = parseTitleInfo(modsTitleInfoExampleElement);

            expect(result.titleType).toStrictEqual(modsTitleInfoTypes[modsTitleInfoExampleElementIndex]);
            expect(result.displayLabel).toStrictEqual(modsTitleInfoDisplayLabels[modsTitleInfoExampleElementIndex]);
            expect(result.nonSort).toStrictEqual(modsTitleInfoNonSorts[modsTitleInfoExampleElementIndex]);
            expect(result.title).toStrictEqual(modsTitleInfoTitles[modsTitleInfoExampleElementIndex]);
            expect(result.subTitle).toStrictEqual(modsTitleInfoSubTitles[modsTitleInfoExampleElementIndex]);
            expect(result.partNumber).toStrictEqual(modsTitleInfoPartNumbers[modsTitleInfoExampleElementIndex]);
            expect(result.partName).toStrictEqual(modsTitleInfoPartNames[modsTitleInfoExampleElementIndex]);
            expect(result.lang).toStrictEqual(modsTitleInfoLangs[modsTitleInfoExampleElementIndex]);
        }
    });

    test('parseName', () => {
        const modsNameExamples = [
            `<mods:name xmlns:mods="${MODS_NAMESPACE}" type="personal">
                <mods:namePart>Arthur Mitchell</mods:namePart>
                <mods:nameIdentifier>http://www.wikidata.org/entity/Q3753500</mods:nameIdentifier>
            </mods:name>`,
            `<mods:name xmlns:mods="${MODS_NAMESPACE}" type="personal">
                <mods:namePart>Arthur Mitchell</mods:namePart>
                <mods:nameIdentifier>http://www.wikidata.org/entity/Q3753500</mods:nameIdentifier>
            </mods:name>`,
            `<mods:name xmlns:mods="${MODS_NAMESPACE}" type="corporate">
                <mods:displayForm>Friedrich-Loeffler-Institut</mods:displayForm>
                 <mods:role>
                    <mods:roleTerm authority="marcrelator" type="code">isb</mods:roleTerm>
                 </mods:role>
                <mods:nameIdentifier type="gnd">10094896-0</mods:nameIdentifier>
            </mods:name>`
        ];


        const modsNameTypes = ["personal", "personal", "corporate"];
        const modsNameDisplayForms = [undefined, undefined, "Friedrich-Loeffler-Institut"];
        const modsNameRoleTerms = [[], [], [{type: "code", text: "isb", authority: "marcrelator"} as RoleTerm]];
        const modsNameNameParts = [[{text: "Arthur Mitchell"}], [{text: "Arthur Mitchell"}], []];
        const modsNameNameIdentifiers = [
            [{text: "http://www.wikidata.org/entity/Q3753500"} as NameIdentifier],
            [{text: "http://www.wikidata.org/entity/Q3753500"} as NameIdentifier],
            [{text: "10094896-0", type: "gnd"} as NameIdentifier]
        ];

        const modsNameExampleElements = modsNameExamples.map((modsNameExample) => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(modsNameExample, "text/xml");
            return xmlDoc.childNodes[0] as Element;
        });

        expect(modsNameExampleElements.length).toBe(3);

        for (const modsNameExampleElementIndex in modsNameExampleElements) {
            const modsNameExampleElement = modsNameExampleElements[modsNameExampleElementIndex];
            const result = parseName(modsNameExampleElement);

            expect(result.nameType).toEqual(modsNameTypes[modsNameExampleElementIndex]);
            expect(result.displayForm).toEqual(modsNameDisplayForms[modsNameExampleElementIndex]);
            expect(result.role).toEqual(modsNameRoleTerms[modsNameExampleElementIndex]);
            expect(result.nameParts).toEqual(modsNameNameParts[modsNameExampleElementIndex]);
            expect(result.nameIdentifier).toEqual(modsNameNameIdentifiers[modsNameExampleElementIndex]);
        }

    });


    test('parseGenre', () => {
        const modsGenreExamples = [
            `<mods:genre xmlns:mods="${MODS_NAMESPACE}" valueURI="http://id.loc.gov/authorities/genreForms/gf2014026098">Exhibition catalogs</mods:genre>`,
            `<mods:genre xmlns:mods="${MODS_NAMESPACE}" valueURI="http://id.loc.gov/authorities/subjects/sh99001275">Exhibitions</mods:genre>`,
            `<mods:genre xmlns:mods="${MODS_NAMESPACE}" authority="marcgt">book</mods:genre>`,
        ];

        const modsGenreValueURIs = [
            "http://id.loc.gov/authorities/genreForms/gf2014026098",
            "http://id.loc.gov/authorities/subjects/sh99001275",
            undefined
        ];

        const modsGenreAuthorities = [
            undefined,
            undefined,
            "marcgt"
        ];

        const modsGenreTexts = [
            "Exhibition catalogs",
            "Exhibitions",
            "book"
        ];

        const modsGenreExampleElements = modsGenreExamples.map((modsGenreExample) => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(modsGenreExample, "text/xml");
            return xmlDoc.childNodes[0] as Element;
        });


        expect(modsGenreExampleElements.length).toBe(3);

        for (const modsGenreExampleElementIndex in modsGenreExampleElements) {
            const modsGenreExampleElement = modsGenreExampleElements[modsGenreExampleElementIndex];
            const result = parseGenre(modsGenreExampleElement);

            expect(result.valueURI).toEqual(modsGenreValueURIs[modsGenreExampleElementIndex]);
            expect(result.authority).toEqual(modsGenreAuthorities[modsGenreExampleElementIndex]);
            expect(result.text).toEqual(modsGenreTexts[modsGenreExampleElementIndex]);
        }
    });

    test('parseHierarchicalGeographic', () => {
        const modsHierarchicalGeographicExamples = [
            `<mods:hierarchicalGeographic xmlns:mods="${MODS_NAMESPACE}">
                <mods:country>Canada</mods:country>
                <mods:city>Vancouver</mods:city>
             </mods:hierarchicalGeographic>`,
            `<mods:hierarchicalGeographic xmlns:mods="${MODS_NAMESPACE}">
                <mods:country>United States</mods:country>
                <mods:state>Mississippi</mods:state>
                <mods:county>Harrison</mods:county>
                <mods:city>Biloxi</mods:city>
            </mods:hierarchicalGeographic>`,
            `<mods:hierarchicalGeographic xmlns:mods="${MODS_NAMESPACE}">
                <mods:country level="1">United Kingdom</mods:country>
                <mods:country level="2">England</mods:country>
                <mods:region>North West</mods:region>
                <mods:county>Cumbria</mods:county>
                <mods:area areaType="national park">Lake District</mods:area>
            </mods:hierarchicalGeographic>`,
            `<mods:hierarchicalGeographic xmlns:mods="${MODS_NAMESPACE}">
                <mods:country>United States</mods:country>
                <mods:state>Rhode Island</mods:state>
                <mods:city>Providence</mods:city>
                <mods:citySection citySectionType="neighborhood" level="1">East Side</mods:citySection>
                <mods:citySection citySectionType="neighborhood" level="2">Blackstone</mods:citySection>
            </mods:hierarchicalGeographic>`
        ];

        const expectedHierarchicalGeographicResults = [
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


        const modsHierarchicalGeographicExampleElements = modsHierarchicalGeographicExamples.map((modsHierarchicalGeographicExample) => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(modsHierarchicalGeographicExample, "text/xml");
            return xmlDoc.childNodes[0] as Element;
        });


        for (const modsHierarchicalGeographicExampleElementIndex in modsHierarchicalGeographicExampleElements) {
            const modsHierarchicalGeographicExampleElement = modsHierarchicalGeographicExampleElements[modsHierarchicalGeographicExampleElementIndex];
            const result = parseHierarchicalGeographic(modsHierarchicalGeographicExampleElement);
            expect(result).toEqual(expectedHierarchicalGeographicResults[modsHierarchicalGeographicExampleElementIndex]);
        }
    });

    test('parseCartographics', () => {
        const modsCartographicsExamples = [
            `<mods:cartographics xmlns:mods="${MODS_NAMESPACE}">
                <mods:coordinates>E 72°--E 148°/N 13°--N 18°</mods:coordinates>
                <mods:scale>1:22,000,000</mods:scale>
                <mods:projection>Conic proj</mods:projection>
            </mods:cartographics>`,
            `<mods:cartographics xmlns:mods="${MODS_NAMESPACE}">
                <mods:coordinates>6 00 S, 71 30 E</mods:coordinates>
            </mods:cartographics>`,
        ];

        const expectedCartographicsResults: Cartographics[] = [
            {
                "type": "Cartographics",
                "coordinates": ["E 72°--E 148°/N 13°--N 18°"],
                "scale": ["1:22,000,000"],
                "projection": ["Conic proj"]
            },
            {
                "type": "Cartographics",
                "coordinates": ["6 00 S, 71 30 E"],
                "scale": [],
                "projection": []
            }];

        const modsCartographicsExampleElements = modsCartographicsExamples.map((modsCartographicsExample) => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(modsCartographicsExample, "text/xml");
            return xmlDoc.childNodes[0] as Element;
        });

        for (const modsCartographicsExampleElementIndex in modsCartographicsExampleElements) {
            const modsCartographicsExampleElement = modsCartographicsExampleElements[modsCartographicsExampleElementIndex];
            const result = parseCartographics(modsCartographicsExampleElement);
            expect(result).toEqual(expectedCartographicsResults[modsCartographicsExampleElementIndex]);
        }
    });

});
