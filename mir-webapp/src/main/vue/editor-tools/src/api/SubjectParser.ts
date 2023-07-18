import {
    Area,
    Cartographics, City, CitySection, Continent, Country, County,
    Genre,
    Geographic, GeographicCode,
    HierarchicalGeographic, Island,
    Name, NameIdentifier, NamePart, Occupation, Region, RoleTerm, State,
    Subject,
    Temporal, Territory,
    TitleInfo,
    Topic, MODS_NAMESPACE
} from "@/api/Subject";


const assertModsElement = (child: Element, ...localName: string[]) => {
    if (localName.indexOf(child.localName) == -1 || child.namespaceURI !== MODS_NAMESPACE) {
        throw new Error("Expected [" + localName.map(n=>"mods:".concat(n)).join(" | ") + "] element");
    }
}
export const parseTopic = (child: Element): Topic => {
    assertModsElement(child, "topic")
    return {
        type: "Topic",
        text: child.textContent || "",
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined
    }
};

export const parseGeographic = (child: Element): Geographic => {
    assertModsElement(child, "geographic");
    return {
        type: "Geographic",
        text: child.textContent || "",
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined
    }
};

export const parseTemporal = (child: Element): Temporal => {
    assertModsElement(child, "temporal");
    return {
        type: "Temporal",
        text: child.textContent || "",
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined,
        point: child.getAttribute("point") as "start" | "end" || undefined,
        keyDate: child.getAttribute("keyDate") === "yes" || undefined,
        qualifier: child.getAttribute("qualifier") as "approximate" | "inferred" | "questionable" || undefined,
        calendar: child.getAttribute("calendar") || undefined,
        encoding: child.getAttribute("encoding") || undefined
    }
};

const titleInfoChild = (child: Element): string => {
    assertModsElement(child, "title", "subTitle", "partNumber", "partName", "nonSort");
    return child.textContent || "";
}


export const parseTitleInfo = (child: Element): TitleInfo => {
    assertModsElement(child, "titleInfo");
    return {
        type: "TitleInfo",
        title: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "title")
            .map(el => titleInfoChild(el as Element)),
        subTitle: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "subTitle")
            .map(el => titleInfoChild(el as Element)),
        partNumber: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "partNumber")
            .map(el => titleInfoChild(el as Element)),
        partName: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "partName")
            .map(el => titleInfoChild(el as Element)),
        nonSort: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "nonSort")
            .map(el => titleInfoChild(el as Element)),
        titleType: child.getAttribute("type") || undefined,
        lang: child.getAttributeNS("http://www.w3.org/XML/1998/namespace", "lang") || undefined,
        displayLabel: child.getAttribute("displayLabel") || undefined,
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined
    }
};

const parseNamePart = (child: Element): NamePart => {
    assertModsElement(child, "namePart");
    return {
        type: child.getAttribute("type") as "family" | "given" | "termsOfAddress" || undefined,
        text: child.textContent || ""
    }
};

const parseRole = (modsRoleElement: Element): RoleTerm[] => {
    assertModsElement(modsRoleElement, "role");
    const roleTerms = [] as RoleTerm[];
    Array.from(modsRoleElement.childNodes)
        .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "roleTerm")
        .forEach((el) => {
            if (el instanceof Element) {
                const roleTerm: RoleTerm = {
                    text: el.textContent || "",
                    type: el.getAttribute("type") as "code" | "text" || undefined,
                    authority: el.getAttribute("authority") || undefined,
                    authorityURI: el.getAttribute("authorityURI") || undefined,
                    valueURI: el.getAttribute("valueURI") || undefined
                }
                roleTerms.push(roleTerm);
            }
        });
    return roleTerms;
}

const parseAffiliation = (child: Element): string => {
    assertModsElement(child, "affiliation");
    return child.textContent || "";
}

const parseNameIdentifier = (child: Element): NameIdentifier => {
    assertModsElement(child, "nameIdentifier");
    return {
        type: child.getAttribute("type") || undefined,
        text: child.textContent || "",
    }
}

export const parseName = (child: Element): Name => {
    assertModsElement(child, "name");
    return {
        type: "Name",
        displayForm: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "displayForm")
            .map(el => el.textContent || "")[0] || undefined,
        nameParts: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "namePart")
            .map(el => parseNamePart(el as Element)),
        role: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "role")
            .map(el => parseRole(el as Element))
            .reduce((acc, val) => acc.concat(val), []),
        affiliation: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "affiliation")
            .map(el => parseAffiliation(el as Element)),
        nameIdentifier: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "nameIdentifier")
            .map(el => parseNameIdentifier(el as Element)),
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined,
        nameType: child.getAttribute("type") as "personal" | "corporate" | "conference" | "family" || undefined,
    }
};

export const parseGenre = (child: Element): Genre => {
    assertModsElement(child, "genre");
    return {
        type: "Genre",
        text: child.textContent || "",
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined,
        genreType: child.getAttribute("type") as "code" | "text" || undefined,
    }
}


export const parseHierarchicalGeographic = (child: Element): HierarchicalGeographic => {
    assertModsElement(child, "hierarchicalGeographic");
    const children = [] as Array<Continent  | Country  | Region | State | Territory | County | City | CitySection | Island | Area>;

    Array.from(child.childNodes)
        .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE)
        .forEach((node) => {
            const el = node as Element;

            const levelAttribute = el.getAttribute("level");
            const result: Continent  | Country  | Region | State | Territory | County | City | CitySection | Island | Area = {
                type: el.localName as "continent" | "country" | "region" | "state" | "territory" | "county" | "city" | "citySection" | "island" | "area",
                level: levelAttribute ? parseInt(levelAttribute) : undefined,
                period: el.getAttribute("period") || undefined,
                text: el.textContent || ""
            }

            if(result.type === "area") {
                result.areaType = el.getAttribute("areaType") || undefined;
            }

            if(result.type === "region") {
                result.regionType = el.getAttribute("regionType") || undefined;
            }

            if(result.type === "state") {
                result.stateType = el.getAttribute("stateType") || undefined;
            }

            if(result.type === "citySection") {
                result.citySectionType = el.getAttribute("citySectionType") || undefined;
            }

            children.push(result);
        });

    return {
        type: "HierarchicalGeographic",
        children,
    }
}

export const parseCartographics = (child: Element): Cartographics => {
    assertModsElement(child, "cartographics");
    return {
        type: "Cartographics",
        coordinates: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "coordinates")
            .map(el => el.textContent || "") || undefined,
        scale: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "scale")
            .map(el => el.textContent || "") || undefined,
        projection: Array.from(child.childNodes)
            .filter(child => child instanceof Element && child.namespaceURI === MODS_NAMESPACE && child.localName === "projection")
            .map(el => el.textContent || "") || undefined,
    }
};

export const parseGeographicCode = (child: Element): GeographicCode => {
    assertModsElement(child, "geographicCode");
  return {
        type: "GeographicCode",
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined,
        text: child.textContent || "",
  }
};

export const parseOccupation = (child: Element): Occupation => {
    assertModsElement(child, "occupation");
    return {
        type: "Occupation",
        text: child.textContent || "",
        authority: child.getAttribute("authority") || undefined,
        authorityURI: child.getAttribute("authorityURI") || undefined,
        valueURI: child.getAttribute("valueURI") || undefined,
    }
}

export const parseSubject = (subjectElement: Element): Subject => {
    assertModsElement(subjectElement, "subject");
    const authority = subjectElement.getAttribute("authority") || undefined;
    const valueURI = subjectElement.getAttribute("valueURI") || undefined;
    const authorityURI = subjectElement.getAttribute("authorityURI") || undefined;

    const subject = {
        authority,
        valueURI,
        authorityURI,
        children: [] as Array<Topic | Geographic | Temporal | TitleInfo | Name | Genre | HierarchicalGeographic | Cartographics | GeographicCode | Occupation>
    };

    subjectElement.childNodes.forEach(child => {
        if (child instanceof Element && child.namespaceURI === MODS_NAMESPACE) {
            switch (child.localName) {
                case "topic":
                    subject.children.push(parseTopic(child));
                    break;
                case "geographic":
                    subject.children.push(parseGeographic(child));
                    break;
                case "temporal":
                    subject.children.push(parseTemporal(child));
                    break;
                case "titleInfo":
                    subject.children.push(parseTitleInfo(child));
                    break;
                case "name":
                    subject.children.push(parseName(child));
                    break;
                case "genre":
                    subject.children.push(parseGenre(child));
                    break;
                case "hierarchicalGeographic":
                    subject.children.push(parseHierarchicalGeographic(child));
                    break;
                case "cartographics":
                    subject.children.push(parseCartographics(child));
                    break;
                case "geographicCode":
                    subject.children.push(parseGeographicCode(child));
                    break;
                case "occupation":
                    subject.children.push(parseOccupation(child));
                    break;
                default:
                    throw new Error(`Unexpected subject child element ${child.localName}`);
            }
        }

    });

    return subject;
};
