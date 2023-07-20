<template>
    <div v-if="props.cartographics">
        <span class="fas fa-map-marker-alt mr-2"></span>
        <div v-if="$props.cartographics.coordinates?.length>0" class="btn-group btn-group-sm" role="group">
            <button :class="`btn btn-sm btn-secondary${model.showMap ? ' active' : ''}`"
                    @click.prevent="model.showMap = !model.showMap">
                {{ i18n["mir.editor.subject.cartographics.display.showMap"] }}
            </button>


            <button :class="`btn btn-sm btn-secondary${!model.hideSecondaryCoords ? ' active' : ''}`"
                    @click.prevent="model.hideSecondaryCoords = !model.hideSecondaryCoords">
                {{ i18n["mir.editor.subject.cartographics.display.showAllCoordinates"] }}
            </button>
        </div>
        <div v-if="props.cartographics.projection?.length>0">{{ props.cartographics.projection.join(",") }}</div>
        <div v-if="props.cartographics.scale?.length>0">
            {{ i18n["mir.editor.subject.cartographics.display.scale"] }}:
            {{ props.cartographics.scale.join(",") }}
        </div>
        <div v-if="props.cartographics.coordinates">
            {{ i18n["mir.editor.subject.cartographics.display.coordinates"] }}:
            <template v-if="props.cartographics.coordinates && model.hideSecondaryCoords">
                {{ shrinkedCoords }}

            </template>
            <template v-else-if="props.cartographics.coordinates">
                <ol v-for="coords in convertedCoords" class="object">
                    <li v-for="coord in coords" class="point">
                        {{ coord.join(",") }}
                    </li>
                </ol>
            </template>
            <div v-if="model.showMap">
                <ol-map :loadTilesWhileAnimating="true" :loadTilesWhileInteracting="true" style="height:400px">

                    <ol-view ref="view"
                             :center="transform(centerOfCoords, 'EPSG:4326', 'EPSG:3857')"
                             :rotation="0"
                             :zoom="model.zoom"
                             projection="EPSG:3857"
                    />

                    <ol-tile-layer>
                        <ol-source-o-s-m/>
                    </ol-tile-layer>

                    <ol-vector-layer>
                        <ol-source-vector>
                            <ol-feature>
                                <ol-geom-multi-polygon
                                    :coordinates="[convertedTransformedCoords]">
                                </ol-geom-multi-polygon>
                                <ol-style>
                                    <ol-style-stroke
                                        :color="'blue'"
                                        :width="3"
                                    ></ol-style-stroke>
                                </ol-style>
                            </ol-feature>
                        </ol-source-vector>
                    </ol-vector-layer>
                </ol-map>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import {transform} from 'ol/proj';
import {computed, defineProps, nextTick, reactive, ref, watch} from "vue";
import {Cartographics} from "@/api/Subject";
import {View} from "ol";
import {boundingExtent, isEmpty} from 'ol/extent';

import * as ol  from "vue3-openlayers";
import {provideTranslations} from "@/api/I18N";
const {Map, MapControls, Layers, Sources, Styles, Geometries, Interactions, Animations} = ol;
const {OlMap, OlView, OlFeature} =Map;
const {OlStyle, OlStyleStroke} = Styles;
const { OlGeomMultiPolygon } = Geometries;
const {OlTileLayer, OlVectorLayer} = Layers;
const {OlSourceOSM, OlSourceVector} = Sources;
const {} = MapControls;

const model = reactive({
    zoom: 7,
    hideSecondaryCoords: true,
    showMap: false
})

const view = ref<any>(null);

watch(() => model.showMap, (zoom) => {
    nextTick(() => {
        if(convertedTransformedCoords.value !== undefined && view.value) {
            const coord = convertedTransformedCoords.value;
            const flatCoord = coord.flat(1)
            const extent = boundingExtent(flatCoord);
            if(!isEmpty(extent)){
                (view.value as View).fit(extent, {});
            }
        }
    });
}, {immediate: false})


const props = defineProps<{ cartographics: Cartographics }>();

const i18n = provideTranslations([
    "mir.editor.subject.cartographics.display.coordinates",
    "mir.editor.subject.cartographics.display.scale",
    "mir.editor.subject.cartographics.display.showMap",
    "mir.editor.subject.cartographics.display.showAllCoordinates",
]);

const centerOfCoords = computed(()=>{
   const bboxes = props.cartographics.coordinates?.map(coordPairs => {
       return convertCoords(coordPairs);
   }).map(coords => {
       return calculateBoundingBox(coords);
   });

   if(!bboxes || bboxes.length === 0){
       return [0,0];
   } else {
       return getCenterOfBoundingBox(combineBoundingBox(bboxes));
   }
});

const convertedTransformedCoords = computed(()=>{
    return props.cartographics.coordinates?.map(coordPairs => {
        return convertCoords(coordPairs).map(coordPair => {
            return transform(coordPair, 'EPSG:4326', 'EPSG:3857');
        });
    });
});

const convertedCoords = computed(()=>{
    return props.cartographics.coordinates?.map(coordPairs => {
        return convertCoords(coordPairs);
    });
});


const shrinkedCoords = computed(()=>{
    return shortenString(props.cartographics.coordinates?.join(" ")||"", 50);
});

const shortenString = (str: string, maxLength: number): string => {
    if(str.length > maxLength){
        return str.substring(0, maxLength) + "...";
    } else {
        return str;
    }
}

const convertCoords = (coordStr: string): number[][] => {
    const coords = coordStr.split(",");
    return coords.map(coordPairStr => {
        const coordPair = coordPairStr.trim().split(" ");
        return [parseFloat(coordPair[0]), parseFloat(coordPair[1])];
    });
}

const calculateBoundingBox = (coords: number[][]): number[] => {
    let minX = Number.MAX_VALUE;
    let minY = Number.MAX_VALUE;
    let maxX = Number.MIN_VALUE;
    let maxY = Number.MIN_VALUE;
    coords.forEach(coord => {
        minX = Math.min(minX, coord[0]);
        minY = Math.min(minY, coord[1]);
        maxX = Math.max(maxX, coord[0]);
        maxY = Math.max(maxY, coord[1]);
    });
    return [minX, minY, maxX, maxY];
}

const combineBoundingBox = (boundingBoxes: number[][]): number[] => {
    let minX = Number.MAX_VALUE;
    let minY = Number.MAX_VALUE;
    let maxX = Number.MIN_VALUE;
    let maxY = Number.MIN_VALUE;
    boundingBoxes.forEach(boundingBox => {
        minX = Math.min(minX, boundingBox[0]);
        minY = Math.min(minY, boundingBox[1]);
        maxX = Math.max(maxX, boundingBox[2]);
        maxY = Math.max(maxY, boundingBox[3]);
    });
    return [minX, minY, maxX, maxY];
}

const getCenterOfBoundingBox = (boundingBox: number[]): number[] => {
    const centerX = (boundingBox[0] + boundingBox[2]) / 2;
    const centerY = (boundingBox[1] + boundingBox[3]) / 2;
    return [centerX, centerY];
}



</script>