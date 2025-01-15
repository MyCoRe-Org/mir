/*
 *  This file is part of ***  M y C o R e  ***
 *  See http://www.mycore.de/ for details.
 *
 *  MyCoRe is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  MyCoRe is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

import {Identifier} from "@/api/SearchProvider";

export interface NameLocator {
    modsIndex: number;
    relatedItemIndex?: number;
    nameIndex: number;
}

export function findNameLocator(anyElement: Element): NameLocator | undefined {
    for (const child of anyElement.children) {
        if (child instanceof HTMLInputElement) {
            const match = child.name.match(/(mods:mods\[(?<modsIndex>[\d+])\]\/)?(mods:relatedItem\[(?<relatedItemIndex>[\d+])\]\/)?mods:name\[(?<nameIndex>\d+)\].*/);
            if (match != null && match.length > 0) {
                const relatedItemGroup = match?.groups?.relatedItemIndex;
                const modsGroup = match?.groups?.modsIndex;
                const nameGroup = match?.groups?.nameIndex || "1";
                if (!nameGroup) {
                    console.error("Name index not found in name locator");
                    return undefined;
                }
                if(!modsGroup){
                    console.error("Mods index not found in name locator");
                    return undefined;
                }
                return {
                    relatedItemIndex: relatedItemGroup ? parseInt(relatedItemGroup) : undefined,
                    modsIndex: parseInt(modsGroup),
                    nameIndex: parseInt(nameGroup)
                }
            }
        }
    }

    if (anyElement.parentElement) {
        return findNameLocator(anyElement.parentElement);
    } else {
        return undefined;
    }
}

export function retrieveDisplayName(nameLocator: NameLocator): string {
    const {relatedItemIndex, nameIndex} = nameLocator;
    let riPart = relatedItemIndex ? `mods:relatedItem[${relatedItemIndex}]/`: "";
    let modsPart = nameLocator.modsIndex ? `mods:mods[${nameLocator.modsIndex}]/` : "";
    const input = document.querySelector(`[name*="${modsPart}${riPart}mods:name[${nameIndex}]/mods:displayForm"]`) as HTMLInputElement;
    return input.value;
}

export function retrieveIsPerson(nameLocator: NameLocator): boolean {
    const {relatedItemIndex, nameIndex} = nameLocator;
    let riPart = relatedItemIndex ? `mods:relatedItem[${relatedItemIndex}]/`: "";
    let modsPart = nameLocator.modsIndex ? `mods:mods[${nameLocator.modsIndex}]/` : "";
    const input = document.querySelector(`[name*="${modsPart}${riPart}mods:name[${nameIndex}]/@type"]`);
    if(input instanceof HTMLInputElement || input instanceof HTMLSelectElement){
        if(input.value == "personal"){
            return true;
        } else {
            return false;
        }
    } else {
        return true;
    }
}

export function storeName(nameLocator: NameLocator, name: string) {
    const {relatedItemIndex, nameIndex} = nameLocator;
    let riPart = relatedItemIndex ? `mods:relatedItem[${relatedItemIndex}]/`: "";
    let modsPart = nameLocator.modsIndex ? `mods:mods[${nameLocator.modsIndex}]/` : "";
    const input = document.querySelector(`[name*="${modsPart}${riPart}mods:name[${nameIndex}]/mods:displayForm"]`) as HTMLInputElement;
    input.value = name;
}

export function storeIsPerson(nameLocator: NameLocator, isPerson: boolean) {
    const {relatedItemIndex, nameIndex} = nameLocator;
    let riPart = relatedItemIndex ? `mods:relatedItem[${relatedItemIndex}]/`: "";
    let modsPart = nameLocator.modsIndex ? `mods:mods[${nameLocator.modsIndex}]/` : "";
    const input = document.querySelector(`[name*="${modsPart}${riPart}mods:name[${nameIndex}]/@type"]`);

    if(input instanceof HTMLInputElement || input instanceof HTMLSelectElement){
        input.value = isPerson ? "personal" : "corporate";
    }
}

export function storeIdentifiers(nameLocator: NameLocator, identifiers: Identifier[]) {
    const {typeMap, identifierMap} = retrieveElementMaps(nameLocator);
    console.log(["storeIdentifiers ", typeMap, identifierMap, identifiers])
    Object.keys(identifierMap).map(key => parseInt(key)).sort().forEach(index => {
        identifierMap[index].value = "";
        typeMap[index].value = "";
    });

    for (let i = 0; i < identifiers.length; i++) {
        typeMap[i + 1].value = identifiers[i].type;
        identifierMap[i + 1].value = identifiers[i].value;
    }
}

export function retrieveIdentifiers(nameLocator: NameLocator): Identifier[] {
    const elementMaps = retrieveElementMaps(nameLocator);

    return Object.keys(elementMaps.identifierMap)
        .map(key => parseInt(key))
        .sort()
        .map(index => {
            const value = elementMaps.identifierMap[index].value;
            const type = elementMaps.typeMap[index].value;
            return {type, value}
        }).filter(identifier => identifier.type != "" && identifier.value != "");
}

export function retrieveElementMaps(nameLocator: NameLocator) {
    const {relatedItemIndex, nameIndex} = nameLocator;
    let riPart = relatedItemIndex ? `mods:relatedItem[${relatedItemIndex}]/`: "";
    let modsPart = nameLocator.modsIndex ? `mods:mods[${nameLocator.modsIndex}]/` : "";
    const elements = document.querySelectorAll(`[name*="${modsPart}${riPart}mods:name[${nameIndex}]/mods:nameIdentifier"]`);
    const typeMap: Record<number, HTMLInputElement> = {};
    const identifierMap: Record<number, HTMLInputElement> = {};

    for (const element of elements) {
        // e.G. /mycoreobject/metadata[1]/def.modsContainer[1]/modsContainer[1]/mods:mods[1]/mods:name[1]/mods:nameIdentifier[8]/@type
        const nameAttribute = element.getAttribute("name");
        if (nameAttribute == null) {
            console.error([`Error while reading attribute name from`, element]);
            continue;
        }

        const nameXpathPart = `mods:name[${nameIndex}]/`;
        const indexOfNameXpathPart = nameAttribute.indexOf(nameXpathPart);

        // e.G. mods:nameIdentifier[8]/@type or mods:nameIdentifier[8]
        const nameIdentifierXpathPart = nameAttribute.substring(indexOfNameXpathPart + nameXpathPart.length);
        const nameSkip = "mods:nameIdentifier[";
        const indexEnd = nameIdentifierXpathPart.indexOf("]", nameSkip.length + 1);
        const index = parseInt(nameIdentifierXpathPart.substring(nameSkip.length, indexEnd));
        const isType = nameIdentifierXpathPart.indexOf("@type") != -1;

        if (isType) {
            typeMap[index] = (element as HTMLInputElement);
        } else {
            identifierMap[index] = (element as HTMLInputElement);
        }

    }
    return {typeMap, identifierMap};
}

