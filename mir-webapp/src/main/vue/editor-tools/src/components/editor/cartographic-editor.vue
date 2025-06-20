<template>
  <div>
        <array-repeater v-model="cartographics.scale" default-content="">
            <template #addButton>
                <button class="btn btn-sm btn-secondary" @click="cartographics.scale.push('')">Add Scale</button><!--**TODO i18n-->
            </template>
            <template #label="content">
                <label  v-if="content.object !== undefined && content.object !== null" :for="`${id}scale${content.index}`">{{ i18n["mir.editor.subject.cartographics.editor.scale"] }}</label>
            </template>

            <template #displayContent="content">
                <input v-if="cartographics.scale"
                       :id="`${id}scale${content.index}`"
                       v-model="cartographics.scale[content.index]"
                       :class="'form-control form-control-sm' + validClass(cartographics.scale[content.index])"
                       type="text" />
                <div class="invalid-feedback">
                    {{ i18n["mir.editor.subject.cartographics.editor.invalid.scale"] }}
                </div>
            </template>
        </array-repeater>
        <array-repeater v-model="cartographics.coordinates" default-content="">
            <template #addButton>
                <button class="btn btn-sm btn-secondary" @click="cartographics.coordinates.push('')">Add coordinates</button> <!--**TODO i18n-->
            </template>
            <template #label="content">
                <label v-if="content.object !== undefined && content.object !== null" :for=" `${id}coordinates${content.index}`"> {{ i18n["mir.editor.subject.cartographics.editor.coordinates"] }}</label>
            </template>

            <template #displayContent="content">
                <input v-if="cartographics.coordinates"
                       :id="`${id}coordinates${content.index}`"
                        v-model="cartographics.coordinates[content.index]"
                       :class="'form-control form-control-sm' + validClass(cartographics.coordinates[content.index])"
                       type="text" />
                <div class="invalid-feedback">
                    {{ i18n["mir.editor.subject.cartographics.editor.invalid.coordinates"] }}
                </div>
            </template>
        </array-repeater>
        <div class="row mt-2">
            <div class="col-12">
                <div class="btn-group btn-group-sm">
                    <button class="btn btn-secondary" aria-label="add Polygon" @click.prevent="addPolygon">
                        <i class="fas fa-plus"></i> {{ i18n["mir.editor.subject.cartographics.editor.add.polygon"] }}
                    </button>
                    <button class="btn btn-secondary" aria-label="add Point" @click.prevent="addPoint">
                        <i class="fas fa-plus"></i> {{ i18n["mir.editor.subject.cartographics.editor.add.point"] }}
                    </button>
                </div>
            </div>
        </div>
        <div class="row mt-2">
            <div class="col-12">
                <ol-map :loadTilesWhileAnimating="true" :loadTilesWhileInteracting="true" style="height:400px">

                    <ol-view ref="view"
                             projection="EPSG:3857"
                    />

                    <ol-tile-layer>
                        <ol-source-o-s-m/>
                    </ol-tile-layer>

                    <ol-vector-layer>
                        <ol-source-vector>
                            <ol-draw-interaction v-if="!!model.searchType" :type="model.searchType" @drawend="drawEnd">

                            </ol-draw-interaction>

                        </ol-source-vector>
                        <ol-source-vector>
                            <ol-feature>
                                <ol-geom-multi-polygon
                                    :coordinates="[convertedTransformedCoords]">
                                </ol-geom-multi-polygon>
                                <ol-style>
                                    <ol-style-stroke
                                        :color="'blue'"
                                        :width="'3'"
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

import {computed, defineEmits, defineProps, nextTick, onMounted, reactive, ref, watch} from "vue";
import {Cartographics} from "@/api/Subject";
import ArrayRepeater from "@/components/editor/array-repeater.vue";
import {useVModel} from "@vueuse/core";
import {transform} from "ol/proj";
import {DrawEvent} from "ol/interaction/Draw";
import {Point, Polygon} from "ol/geom";
import {boundingExtent, isEmpty} from "ol/extent";
import {View} from "ol";


import * as ol  from "vue3-openlayers";
import {provideTranslations} from "@/api/I18N";
const {Map, Layers, Sources, Styles, Geometries, Interactions} = ol;
const {OlMap, OlView, OlFeature} =Map;
const {OlStyle, OlStyleStroke} = Styles;
const { OlGeomMultiPolygon } = Geometries;
const {OlTileLayer, OlVectorLayer} = Layers;
const {OlSourceOSM, OlSourceVector} = Sources;
const {OlDrawInteraction} = Interactions;




const emit = defineEmits(['update:modelValue', "invalid:data", "valid:data"])

const id = "cartographics" + Math.random().toString(36).substring(2, 15);

const props = defineProps<{
    modelValue: Cartographics
}>();

const model = reactive({
    searchType: null as any,
});

const view = ref<any>(null);

const cartographics = useVModel(props, 'modelValue', emit);

const addPolygon = () => {
    model.searchType = 'Polygon';
}

const addPoint = () => {
    model.searchType = 'Point';
}

const i18n = provideTranslations([
    "mir.editor.subject.cartographics.editor.scale",
    "mir.editor.subject.cartographics.editor.invalid.scale",
    "mir.editor.subject.cartographics.editor.coordinates",
    "mir.editor.subject.cartographics.editor.invalid.coordinates",
    "mir.editor.subject.cartographics.editor.add.polygon",
    "mir.editor.subject.cartographics.editor.add.point",
]);

onMounted(() => {
    nextTick(()=>{
        if(convertedTransformedCoords.value !== undefined && view.value) {
            const coord = convertedTransformedCoords.value;
            const flatCoord = coord.flat(1)
            const extent = boundingExtent(flatCoord);
            if(!isEmpty(extent)){
                (view.value as View).fit(extent, {});
            }
        }
    });
});

const drawEnd = (e:DrawEvent)=> {
    const geometry = e.feature.getGeometry();
    if( model.searchType == "Polygon" && geometry != null){
        const poly = geometry as Polygon;
        const translatedPoly = poly.transform('EPSG:3857', 'EPSG:4326') as Polygon;
        const translatedCoordinates = translatedPoly.getCoordinates(true)[0];
        const coordinates = translatedCoordinates.map(coord => {
            return coord[0] + " " + coord[1];
        }).join(",");
        cartographics.value.coordinates?.push(coordinates);
    } else if (model.searchType == "Point" && geometry != null) {
        const point = geometry as Point;
        const translatedPoint = point.transform('EPSG:3857', 'EPSG:4326') as Point;
        const translatedCoordinates = translatedPoint.getCoordinates();
        const coordinates = translatedCoordinates[0] + " " + translatedCoordinates[1];
        cartographics.value.coordinates?.push(coordinates);
    }

    model.searchType = null;

}

const centerOfCoords = computed(()=>{
    const bboxes = cartographics.value.coordinates?.map(coordPairs => {
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
    return cartographics.value.coordinates?.map(coordPairs => {
        return convertCoords(coordPairs).map(coordPair => {
            return transform(coordPair, 'EPSG:4326', 'EPSG:3857');
        });
    });
});


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

watch(cartographics, (value) => {
    if (value.coordinates?.filter(coord => !valid(coord)).length === 0 &&
        value.scale?.filter(scale => !valid(scale)).length === 0) {
        emit('valid:data');
    } else {
        emit('invalid:data');
    }

}, {deep: true});

const validClass = (value: string) => {
    return valid(value) ? ' is-valid' : ' is-invalid';
};

const valid = (value: string) => {
    return !(value === undefined || value === null || value.trim() === '');
};


</script>

<style>

</style>