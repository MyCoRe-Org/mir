<template>
    <div class="btn-group btn-group-sm" role="group">
        <button v-if="editVisible"
                :title="props.editTitle"
                :class="`btn btn-sm btn-secondary${editEnabled? '':' disabled'}${editPressed? ' active':''}`"
                type="button"
                aria-label="edit button"
                v-on:click.prevent="editClicked()">
            <i class="fas fa-edit fa-fw"/>
        </button>
        <button v-if="plusVisible"
                :title="props.plusTitle"
                :class="`btn btn-sm btn-secondary${plusEnabled? '':' disabled'}`"
                type="button"
                aria-label="Plus Button"
                v-on:click.prevent="plusClicked()">
            <i class="fas fa-plus fa-fw"/>
        </button>
        <button v-if="minusVisible"
                :title="props.minusTitle"
                :class="`btn btn-sm btn-secondary${minusEnabled? '':' disabled'}`"
                type="button"
                aria-label="Minus Button"
                v-on:click.prevent="minusClicked()">
            <i class="fas fa-minus fa-fw"/>
        </button>
        <button v-if="upVisible"
                :title="props.upTitle"
                :class="`btn btn-sm btn-secondary${upEnabled? '':' disabled'}`"
                type="button"
                v-on:click.prevent="upClicked()">
            <i class="fas fa-arrow-up fa-fw"/>
        </button>
        <button v-if="downVisible"
                :title="props.downTitle"
                :class="`btn btn-sm btn-secondary${downEnabled? '':' disabled'}`"
                type="button"
                v-on:click.prevent="downClicked()">
            <i class="fas fa-arrow-down fa-fw"/>
        </button>
    </div>
</template>

<script setup lang="ts">

interface Props {
    plusEnabled: boolean,
    minusEnabled: boolean,
    plusVisible?: boolean,
    minusVisible?: boolean
    upEnabled?: boolean,
    upVisible?: boolean,
    downEnabled?: boolean,
    downVisible?: boolean,
    editEnabled: boolean,
    editVisible?: boolean
    editPressed?: boolean,
    plusTitle?: string,
    minusTitle?: string,
    upTitle?: string,
    downTitle?: string,
    editTitle?: string
}

const props = withDefaults(defineProps<Props>(), {
    editEnabled: false,
    plusEnabled: true,
    minusEnabled: true,
    editVisible: false,
    plusVisible: true,
    minusVisible: true,
    upEnabled: false,
    upVisible: false,
    downEnabled: false,
    downVisible: false,
    editPressed: false
});

const emit = defineEmits<{
    plusClicked: [],
    minusClicked: [],
    upClicked: [],
    downClicked: [],
    editClicked: []
}>();

const plusClicked = () => {
    if (props.plusEnabled && props.plusVisible) {
        emit('plusClicked');
    }
}

const minusClicked = () => {
    if (props.minusEnabled && props.minusVisible) {
        emit('minusClicked');
    }
}

const upClicked = () => {
    if (props.upEnabled && props.upVisible) {
        emit('upClicked');
    }
}

const downClicked = () => {
    if (props.downEnabled && props.downVisible) {
        emit('downClicked');
    }
}

const editClicked = () => {
    if (props.editEnabled && props.editVisible) {
        emit('editClicked');
    }
}

</script>

<script>

</script>