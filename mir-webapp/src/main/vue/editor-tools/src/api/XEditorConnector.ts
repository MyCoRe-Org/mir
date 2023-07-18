import {Subject} from "@/api/Subject";
import {outputSubject} from "@/api/SubjectXMLOutputter";
import {parseSubject} from "@/api/SubjectParser";

export const storeSubject = (subject:Subject, root: HTMLElement) => {
    const input = root.parentElement?.parentElement?.querySelector(`.subjectXML`);
    if(input instanceof HTMLInputElement){
        const result = outputSubject(subject);
        input.value = new XMLSerializer().serializeToString(result);
    } else {
        throw new Error("Could not find subjectXML input");
    }
}

export const retrieveSubject = (root: HTMLElement): Subject => {
    const input = root.parentElement?.parentElement?.querySelector(`.subjectXML`);
    if(input instanceof HTMLInputElement){
        const xml = input.value;
        let subject: Subject;
        if(input.value == ""){
            subject = {
                children: [],
            }
        } else {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(xml, "text/xml");
            subject = parseSubject(xmlDoc.children.item(0) as Element);
        }

        return subject;
    } else {
        throw new Error("Could not find subjectXML input");
    }

};

export interface EditorSettings {
    /**
     * Comma separated list of searchable elements. If contains *, all elements are searchable.
     * If empty, no elements are searchable.
     */
    searchable: ("Topic" | "Geographic" | "Institution" | "Person" | "Family" | "Conference" | "TitleInfo" | "Cartographic" | "*"|"")[],

    /**
     * Comma separated list of editable elements. If contains *, all elements are editable. If empty, no elements are
     * editable.
     */
    editor: ("Topic" | "Geographic" | "Institution" | "Person" | "Family" | "Conference" | "TitleInfo" | "Cartographic"|"*"|"")[],

    /**
     * If true the editor only allows editing of one subelement. If the subject contains more than one subelement, the
     * editor is disabled. If the type is "geographicPair" the editor allows editing of two subelements.
     */
    simple: boolean|"geographicPair",

    /**
     * If true there must be at least one subelement. If the subject contains no subelements the editor will print
     * a warning.
     */
    required: boolean|string[],
}

export const possibleTypes = ["Topic", "Geographic" , "Institution" , "Person" , "Family" , "Conference" , "TitleInfo" , "Cartographic"];

export const retrieveSettings = (root: HTMLElement): EditorSettings => {
    const input = root.parentElement;
    if(input instanceof Element){
        const settings:EditorSettings = {
            searchable: [],
            editor: []
        } as any;

        const editor = input.getAttribute("data-editor") || "*";
        const searchable = input.getAttribute("data-searchable") || "*";
        const simpleStr = input.getAttribute("data-simple") || "false";
        const requiredStr= input.getAttribute("data-required") || "false";

        if(simpleStr != "true" && simpleStr != "false" && simpleStr != "geographicPair"){
            throw new Error(`Unknown value ${simpleStr} for data-simple. Expected true, false or geographicPair`);
        } else if(simpleStr == "true" || simpleStr == "false") {
            settings.simple = simpleStr == "true";
        } else {
            settings.simple = "geographicPair";
        }

        if(requiredStr == "true" || requiredStr == "false") {
            settings.required = requiredStr == "true";
        } else {
            settings.required = requiredStr.split(",");
            settings.required = settings.required.filter((value, index, array) => {
               const includes = possibleTypes.includes(value);
                if(!includes){
                    console.warn(`Unknown type ${value} in required list`);
                }
                return includes;
            });
        }

        if(editor == "*"){
            settings.editor = Array.of(...possibleTypes) as any;
        } else {
            settings.editor = editor.split(",") as any;
            settings.editor = settings.editor.filter((value, index, array) => {
                const includes = possibleTypes.includes(value);
                if(!includes){
                    console.warn(`Unknown type ${value} in editor list`);
                }
                return includes;
            });
        }

        if(searchable == "*"){
            settings.searchable = Array.of(...possibleTypes) as any;
        } else {
            settings.searchable = searchable.split(",") as any;
            settings.searchable = settings.searchable.filter((value, index, array) => {
                const includes = possibleTypes.includes(value);
                if(!includes){
                    console.warn(`Unknown type ${value} in searchable list`);
                }
                return includes;
            });
        }


        console.log(settings);
        return settings
    }
    throw new Error("Could not find subjectXML input");
}