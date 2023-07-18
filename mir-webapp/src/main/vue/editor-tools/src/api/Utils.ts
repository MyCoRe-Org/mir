export const getAuthorityBadgeName = async (authorityId: string) => {
    switch (authorityId) {
        case "gnd":
            return "GND";
        default:
            return authorityId;
    }
}