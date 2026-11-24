<?xml version="1.0" encoding="UTF-8"?>
<!--
  Shows the possible duplicates of an object in the workflow box. This is meant for objects that do not
  pass through the editor (e.g. imported by an interface), so the duplicate check of the import dialog
  never ran for them. The link leads to the duplicate management, filtered by this object, where the
  pair can be marked as "no duplicate".
-->
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrobject="http://www.mycore.de/xslt/object"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:param name="MIR.Workflow.Dedup" select="'false'"/>
  <xsl:param name="MIR.Workflow.Dedup.States" select="''"/>
  <xsl:param name="MIR.Workflow.Dedup.MaxListed" select="'3'"/>
  <xsl:param name="MIR.Dedup.FilterDocumentsInStates" select="''"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template match="mycoreobject" mode="possibleDuplicates">
    <xsl:variable name="currentStatus" select="service/servstates/servstate[@classid='state']/@categid"/>
    <xsl:if test="normalize-space($MIR.Workflow.Dedup) = 'true'
                  and $currentStatus = tokenize(normalize-space($MIR.Workflow.Dedup.States), '\s*,\s*')
                  and mcracl:check-permission((), 'manage-deduplication')">
      <xsl:variable name="filteredStates"
                    select="tokenize(normalize-space($MIR.Dedup.FilterDocumentsInStates), '\s*,\s*')"/>
      <!--
        Objects that no longer exist, that the current user may not read or that are in a filtered state are
        neither listed nor counted. Every remaining object is loaded once, its title is kept for the list.
      -->
      <xsl:variable name="duplicates" as="element(duplicate)*">
        <xsl:for-each select="document(concat('dedup:duplicates:', @ID))/duplicates/duplicate
                              [mcracl:check-permission(@id, 'read')]">
          <xsl:variable name="other" select="mcrobject:get(@id, false())/mycoreobject"/>
          <xsl:if test="exists($other)
                        and not($other/service/servstates/servstate[@classid='state']/@categid = $filteredStates)">
            <xsl:variable name="mods" select="$other/metadata/def.modsContainer/modsContainer/mods:mods"/>
            <duplicate id="{@id}"
                       title="{normalize-space(($mods/mods:titleInfo[not(@type)], $mods/mods:titleInfo)[1]
                                               /mods:title[1])}">
              <xsl:copy-of select="criterion"/>
            </duplicate>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="exists($duplicates)">
        <xsl:variable name="maxListed" as="xs:integer"
                      select="if (normalize-space($MIR.Workflow.Dedup.MaxListed) castable as xs:integer)
                              then xs:integer(normalize-space($MIR.Workflow.Dedup.MaxListed))
                              else 3"/>
        <div class="workflow-box mir-workflow-dedup">
          <p>
            <xsl:value-of select="mcri18n:translate-with-params('mir.workflow.dedup.found',
                                  string(count($duplicates)))"/>
          </p>
          <ul>
            <xsl:for-each select="$duplicates[position() le $maxListed]">
              <li>
                <a href="{$WebApplicationBaseURL}receive/{@id}">
                  <xsl:value-of select="if (string-length(@title) gt 0) then @title else @id"/>
                </a>
                <small class="text-muted">
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="string-join(distinct-values(criterion/@type), ', ')"/>
                  <xsl:text>)</xsl:text>
                </small>
              </li>
            </xsl:for-each>
            <xsl:if test="count($duplicates) gt $maxListed">
              <li>
                <xsl:value-of select="mcri18n:translate-with-params('mir.workflow.dedup.more',
                                      string(count($duplicates) - $maxListed))"/>
              </li>
            </xsl:if>
          </ul>
          <a class="btn btn-sm btn-primary" href="{$WebApplicationBaseURL}dedup/?id={@ID}&amp;showReturn=true">
            <xsl:value-of select="mcri18n:translate('mir.workflow.dedup.manage')"/>
          </a>
        </div>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
