<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

    <xsl:param name="WebApplicationBaseURL"/>
    <xsl:output method="text" media-type="application/json" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:variable name="status" select="/mycoreobject/service/servstates/servstate[@classid='state']/@categid"/>
        <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods"/>
        <xsl:variable name="embargo" select="$mods/mods:accessCondition[@type='embargo']"/>
        <xsl:variable name="publicationDate"
                      select="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"/>
        <xsl:variable name="xmlNode">
            <fn:map>
                <fn:string key="status">
                    <xsl:choose>
                        <xsl:when test="$status='published' and count($embargo)=0">
                            <xsl:text>published</xsl:text>
                        </xsl:when>
                        <xsl:when test="$status='published' and count($embargo)&gt;0">
                            <xsl:text>embargoed</xsl:text>
                        </xsl:when>
                        <xsl:when test="$status='imported'">
                            <xsl:text>pending</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>refused</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </fn:string>
                <xsl:choose>
                    <xsl:when test="count($embargo)&gt;0">
                        <fn:string key="publication_date">
                            <xsl:value-of select="$embargo/text()"/>
                        </fn:string>
                    </xsl:when>
                    <xsl:when test="count($publicationDate)&gt;0">
                        <fn:string key="publication_date">
                            <xsl:value-of select="$publicationDate"/>
                        </fn:string>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="count(/mycoreobject/structure/derobjects/derobject[fn:contains(maindoc/text(), '.pdf')])&gt;0">
                    <xsl:variable name="derivate"
                                  select="/mycoreobject/structure/derobjects/derobject[fn:contains(maindoc/text(), '.pdf')]"/>
                    <fn:string key="pdf_url">
                        <xsl:value-of select="concat($WebApplicationBaseURL,
                        'servlets/MCRFileNodeServlet/',
                        $derivate/@xlink:href,
                        '/',
                        $derivate/maindoc/text())"/>
                    </fn:string>
                </xsl:if>
            </fn:map>
        </xsl:variable>
        <xsl:copy-of select="fn:xml-to-json($xmlNode)"/>
    </xsl:template>

</xsl:stylesheet>
