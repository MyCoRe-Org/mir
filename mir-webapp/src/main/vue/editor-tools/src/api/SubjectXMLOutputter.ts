import {
    Cartographics,
    Genre,
    Geographic, GeographicCode,
    HierarchicalGeographic,
    MODS_NAMESPACE,
    Name, Occupation, Subject,
    Temporal,
    TitleInfo,
    Topic
} from "@/api/Subject";


export const outputTopic = (topic: Topic): Element => {
    const topicElement = document.createElementNS(MODS_NAMESPACE, "mods:topic");
    topicElement.textContent = topic.text;
    if (topic.authority) {
        topicElement.setAttribute("authority", topic.authority);
    }
    if (topic.authorityURI) {
        topicElement.setAttribute("authorityURI", topic.authorityURI);
    }
    if (topic.valueURI) {
        topicElement.setAttribute("valueURI", topic.valueURI);
    }
    if(topic.lang) {
        topicElement.setAttributeNS("http://www.w3.org/XML/1998/namespace", "xml:lang", topic.lang);
    }
    return topicElement;
}

export const outputGeographic = (geographic: Geographic): Element => {
    const geographicElement = document.createElementNS(MODS_NAMESPACE, "mods:geographic");
    geographicElement.textContent = geographic.text;
    if (geographic.authority) {
        geographicElement.setAttribute("authority", geographic.authority);
    }
    if (geographic.authorityURI) {
        geographicElement.setAttribute("authorityURI", geographic.authorityURI);
    }
    if (geographic.valueURI) {
        geographicElement.setAttribute("valueURI", geographic.valueURI);
    }
    if (geographic.lang) {
        geographicElement.setAttributeNS("http://www.w3.org/XML/1998/namespace", "xml:lang", geographic.lang);
    }

    return geographicElement;
}

export const outputTemporal = (temporal: Temporal): Element => {
    const temporalElement = document.createElementNS(MODS_NAMESPACE, "mods:temporal");
    temporalElement.textContent = temporal.text;
    if (temporal.authority) {
        temporalElement.setAttribute("authority", temporal.authority);
    }
    if (temporal.authorityURI) {
        temporalElement.setAttribute("authorityURI", temporal.authorityURI);
    }
    if (temporal.valueURI) {
        temporalElement.setAttribute("valueURI", temporal.valueURI);
    }
    if (temporal.point) {
        temporalElement.setAttribute("point", temporal.point);
    }
    if (temporal.keyDate) {
        temporalElement.setAttribute("keyDate", "yes");
    }
    if (temporal.qualifier) {
        temporalElement.setAttribute("qualifier", temporal.qualifier);
    }
    if (temporal.calendar) {
        temporalElement.setAttribute("calendar", temporal.calendar);
    }
    if (temporal.encoding) {
        temporalElement.setAttribute("encoding", temporal.encoding);
    }
    if (temporal.lang) {
        temporalElement.setAttributeNS("http://www.w3.org/XML/1998/namespace", "xml:lang", temporal.lang);
    }
    return temporalElement;
}

export const outputTitleInfo = (titleInfo: TitleInfo): Element => {
    const titleInfoElement = document.createElementNS(MODS_NAMESPACE, "mods:titleInfo");

    if (titleInfo.authority) {
            titleInfoElement.setAttribute("authority", titleInfo.authority);
    }

    if (titleInfo.authorityURI) {
        titleInfoElement.setAttribute("authorityURI", titleInfo.authorityURI);
    }

    if (titleInfo.valueURI) {
        titleInfoElement.setAttribute("valueURI", titleInfo.valueURI);
    }

    if (titleInfo.displayLabel) {
        titleInfoElement.setAttribute("displayLabel", titleInfo.displayLabel);
    }
    if (titleInfo.titleType) {
        titleInfoElement.setAttribute("type", titleInfo.titleType);
    }

    if (titleInfo.lang) {
        titleInfoElement.setAttributeNS("http://www.w3.org/XML/1998/namespace", "xml:lang", titleInfo.lang);
    }

    titleInfo.title.forEach(title => {
        const titleElement = document.createElementNS(MODS_NAMESPACE, "mods:title");
        titleElement.textContent = title;
        titleInfoElement.appendChild(titleElement);
    });

    titleInfo.subTitle.forEach(subTitle => {
        const subTitleElement = document.createElementNS(MODS_NAMESPACE, "mods:subTitle");
        subTitleElement.textContent = subTitle;
        titleInfoElement.appendChild(subTitleElement);
    });

    titleInfo.partNumber.forEach(partNumber => {
        const partNumberElement = document.createElementNS(MODS_NAMESPACE, "mods:partNumber");
        partNumberElement.textContent = partNumber;
        titleInfoElement.appendChild(partNumberElement);
    });

    titleInfo.partName.forEach(partName => {
        const partNameElement = document.createElementNS(MODS_NAMESPACE, "mods:partName");
        partNameElement.textContent = partName;
        titleInfoElement.appendChild(partNameElement);
    });

    titleInfo.nonSort.forEach(nonSort => {
        const nonSortElement = document.createElementNS(MODS_NAMESPACE, "mods:nonSort");
        nonSortElement.textContent = nonSort;
        titleInfoElement.appendChild(nonSortElement);

    });



    return titleInfoElement;
};

export const outputName = (name: Name): Element => {
    const nameElement = document.createElementNS(MODS_NAMESPACE, "mods:name");

    if (name.nameType) {
        nameElement.setAttribute("type", name.nameType);
    }

    if (name.authority) {
        nameElement.setAttribute("authority", name.authority);
    }

    if (name.authorityURI) {
        nameElement.setAttribute("authorityURI", name.authorityURI);
    }

    if (name.valueURI) {
        nameElement.setAttribute("valueURI", name.valueURI);
    }

    if (name.displayForm) {
        const displayFormElement = document.createElementNS(MODS_NAMESPACE, "mods:displayForm");
        displayFormElement.textContent = name.displayForm;
        nameElement.appendChild(displayFormElement);
    }

    name.nameParts.forEach(namePart => {
        const namePartElement = document.createElementNS(MODS_NAMESPACE, "mods:namePart");
        namePartElement.textContent = namePart.text;
        if (namePart.type) {
            namePartElement.setAttribute("type", namePart.type);
        }
        nameElement.appendChild(namePartElement);
    });

    name.nameIdentifier.forEach(nameIdentifier => {
        const nameIdentifierElement = document.createElementNS(MODS_NAMESPACE, "mods:nameIdentifier");
        nameIdentifierElement.textContent = nameIdentifier.text;
        if (nameIdentifier.type) {
            nameIdentifierElement.setAttribute("type", nameIdentifier.type);
        }
        nameElement.appendChild(nameIdentifierElement);
    });

    name.affiliation.forEach(affiliation => {
        const affiliationElement = document.createElementNS(MODS_NAMESPACE, "mods:affiliation");
        affiliationElement.textContent = affiliation;
        nameElement.appendChild(affiliationElement);
    });

    if (name.role.length > 0) {
        const roleElement = document.createElementNS(MODS_NAMESPACE, "mods:role");
        name.role.forEach(role => {
            const roleTermElement = document.createElementNS(MODS_NAMESPACE, "mods:roleTerm");
            if (role.text) {
                roleTermElement.textContent = role.text;
            }

            if (role.authority) {
                roleTermElement.setAttribute("authority", role.authority);
            }

            if (role.authorityURI) {
                roleTermElement.setAttribute("authorityURI", role.authorityURI);
            }

            if (role.valueURI) {
                roleTermElement.setAttribute("valueURI", role.valueURI);
            }

            if (role.type) {
                roleTermElement.setAttribute("type", role.type);
            }

            roleElement.appendChild(roleTermElement);
        });
        nameElement.appendChild(roleElement);
    }

    if (name.lang) {
        nameElement.setAttributeNS("http://www.w3.org/XML/1998/namespace", "xml:lang", name.lang);
    }

    return nameElement;

}


export const outputGenre = (genre: Genre): Element => {
    const genreElement = document.createElementNS(MODS_NAMESPACE, "mods:genre");

    if (genre.authority) {
        genreElement.setAttribute("authority", genre.authority);
    }

    if (genre.authorityURI) {
        genreElement.setAttribute("authorityURI", genre.authorityURI);
    }

    if (genre.valueURI) {
        genreElement.setAttribute("valueURI", genre.valueURI);
    }

    if (genre.text) {
        genreElement.textContent = genre.text;
    }

    if (genre.genreType) {
        genreElement.setAttribute("type", genre.genreType);
    }

    if(genre.lang) {
        genreElement.setAttributeNS("http://www.w3.org/XML/1998/namespace", "xml:lang", genre.lang);
    }

    return genreElement;
}

export const outputHierarchicalGeographic = (hierarchicalGeographic: HierarchicalGeographic): Element => {
    const hierarchicalGeographicElement = document.createElementNS(MODS_NAMESPACE, "mods:hierarchicalGeographic");

    hierarchicalGeographic.children.forEach(child => {
        const childElement = document.createElementNS(MODS_NAMESPACE, `mods:${child.type}`);
        childElement.textContent = child.text;
        hierarchicalGeographicElement.appendChild(childElement);

        if (child.type === "citySection" && child.citySectionType) {
            childElement.setAttribute("citySectionType", child.citySectionType);
        }

        if (child.type === "area" && child.areaType) {
            childElement.setAttribute("areaType", child.areaType);
        }

        if (child.type === "region" && child.regionType) {
            childElement.setAttribute("regionType", child.regionType);
        }

        if (child.type === "state" && child.stateType) {
            childElement.setAttribute("stateType", child.stateType);
        }

        if (child.authority) {
            childElement.setAttribute("authority", child.authority);
        }

        if (child.authorityURI) {
            childElement.setAttribute("authorityURI", child.authorityURI);
        }

        if (child.valueURI) {
            childElement.setAttribute("valueURI", child.valueURI);
        }

        if (child.period) {
            childElement.setAttribute("period", child.period);
        }
    });

    return hierarchicalGeographicElement;

}

export const outputCartographics = (cartographics: Cartographics): Element => {
    const cartographicsElement = document.createElementNS(MODS_NAMESPACE, "mods:cartographics");

    if (cartographics.scale) {
        cartographics.scale.forEach(scale => {
            const scaleElement = document.createElementNS(MODS_NAMESPACE, "mods:scale");
            scaleElement.textContent = scale;
            cartographicsElement.appendChild(scaleElement);
        });
    }

    if (cartographics.projection) {
        cartographics.projection.forEach(projection => {
            const projectionElement = document.createElementNS(MODS_NAMESPACE, "mods:projection");
            projectionElement.textContent = projection;
            cartographicsElement.appendChild(projectionElement);
        });
    }

    if (cartographics.coordinates) {
        cartographics.coordinates.forEach(coordinates => {
            const coordinatesElement = document.createElementNS(MODS_NAMESPACE, "mods:coordinates");
            coordinatesElement.textContent = coordinates;
            cartographicsElement.appendChild(coordinatesElement);
        });
    }

    return cartographicsElement;
};

export const outputGeographicCode = (geographicCode: GeographicCode): Element => {
    const geographicCodeElement = document.createElementNS(MODS_NAMESPACE, "mods:geographicCode");

    if (geographicCode.authority) {
        geographicCodeElement.setAttribute("authority", geographicCode.authority);
    }

    if (geographicCode.authorityURI) {
        geographicCodeElement.setAttribute("authorityURI", geographicCode.authorityURI);
    }

    if (geographicCode.valueURI) {
        geographicCodeElement.setAttribute("valueURI", geographicCode.valueURI);
    }

    if (geographicCode.text) {
        geographicCodeElement.textContent = geographicCode.text;
    }

    return geographicCodeElement;
}

export const outputOccupation = (occupation: Occupation): Element => {
    const occupationElement = document.createElementNS(MODS_NAMESPACE, "mods:occupation");

    if (occupation.authority) {
        occupationElement.setAttribute("authority", occupation.authority);
    }

    if (occupation.authorityURI) {
        occupationElement.setAttribute("authorityURI", occupation.authorityURI);
    }

    if (occupation.valueURI) {
        occupationElement.setAttribute("valueURI", occupation.valueURI);
    }

    if (occupation.text) {
        occupationElement.textContent = occupation.text;
    }

    return occupationElement;
}

export const outputSubject = (subject: Subject): Element => {
    const subjectElement = document.createElementNS(MODS_NAMESPACE, "mods:subject");

    if (subject.authority) {
        subjectElement.setAttribute("authority", subject.authority);
    }

    if (subject.authorityURI) {
        subjectElement.setAttribute("authorityURI", subject.authorityURI);
    }

    if (subject.valueURI) {
        subjectElement.setAttribute("valueURI", subject.valueURI);
    }

    subject.children.forEach(child => {
        switch (child.type) {
            case "Topic":
                subjectElement.appendChild(outputTopic(child));
                break;
            case "Geographic":
                subjectElement.appendChild(outputGeographic(child));
                break;
            case "Temporal":
                subjectElement.appendChild(outputTemporal(child));
                break;
            case "TitleInfo":
                subjectElement.appendChild(outputTitleInfo(child));
                break;
            case "Name":
                subjectElement.appendChild(outputName(child));
                break;
            case "Genre":
                subjectElement.appendChild(outputGenre(child));
                break;
            case "HierarchicalGeographic":
                subjectElement.appendChild(outputHierarchicalGeographic(child));
                break;
            case "Cartographics":
                subjectElement.appendChild(outputCartographics(child));
                break;
            case "Occupation":
                subjectElement.appendChild(outputOccupation(child));
                break;
            case "GeographicCode":
                subjectElement.appendChild(outputGeographicCode(child));
                break;
            default:
                break;
        }

    });
    return subjectElement;

}