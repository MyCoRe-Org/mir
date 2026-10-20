<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                exclude-result-prefixes="mods">
    <!-- Names -->
    <xsl:template name="printPersonName">
        <xsl:param name="node" />
        <xsl:choose>
            <xsl:when test="$node/mods:namePart">
                <xsl:choose>
                    <xsl:when test="$node/mods:namePart[@type='given'] and $node/mods:namePart[@type='family']">
                        <xsl:value-of select="concat($node/mods:namePart[@type='family'], ', ', $node/mods:namePart[@type='given'])" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$node/mods:namePart" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$node/mods:displayForm">
                <xsl:value-of select="$node/mods:displayForm" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$node" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
