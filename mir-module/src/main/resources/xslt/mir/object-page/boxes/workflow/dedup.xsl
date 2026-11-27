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
  xmlns:mirdedup="http://www.mycore.de/mir/xslt/dedup"
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
    <xsl:variable name="maxListed" as="xs:integer"
                  select="if (normalize-space($MIR.Workflow.Dedup.MaxListed) castable as xs:integer)
                          then xs:integer(normalize-space($MIR.Workflow.Dedup.MaxListed))
                          else 3"/>
    <xsl:if test="normalize-space($MIR.Workflow.Dedup) = 'true'
                  and $maxListed gt 0
                  and $currentStatus = tokenize(normalize-space($MIR.Workflow.Dedup.States), '\s*,\s*')
                  and mcracl:check-permission((), 'manage-deduplication')">
      <xsl:variable name="filteredStates"
                    select="tokenize(normalize-space($MIR.Dedup.FilterDocumentsInStates), '\s*,\s*')"/>
      <!--
        Objects that no longer exist, that the current user may not read or that are in a filtered state are
        skipped. The candidates are only checked until MaxListed of them are found, every checked object is
        loaded once and its title is kept for the list.
      -->
      <xsl:variable name="duplicates" as="element(duplicate)*">
        <xsl:iterate select="document(concat('dedup:duplicates:', @ID))/duplicates/duplicate">
          <xsl:param name="found" as="element(duplicate)*" select="()"/>
          <xsl:on-completion select="$found"/>
          <xsl:variable name="other" as="element(mycoreobject)?"
                        select="if (mcracl:check-permission(@id, 'read'))
                                then mcrobject:get(@id, false())/mycoreobject
                                else ()"/>
          <xsl:variable name="listed" as="element(duplicate)?">
            <xsl:if test="exists($other)
                          and not($other/service/servstates/servstate[@classid='state']/@categid = $filteredStates)">
              <xsl:variable name="mods" select="$other/metadata/def.modsContainer/modsContainer/mods:mods"/>
              <duplicate id="{@id}"
                         title="{normalize-space(($mods/mods:titleInfo[not(@type)], $mods/mods:titleInfo)[1]
                                                 /mods:title[1])}">
                <xsl:copy-of select="criterion"/>
              </duplicate>
            </xsl:if>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="count(($found, $listed)) ge $maxListed">
              <xsl:break select="($found, $listed)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:next-iteration>
                <xsl:with-param name="found" select="($found, $listed)"/>
              </xsl:next-iteration>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:iterate>
      </xsl:variable>
      <xsl:if test="exists($duplicates)">
        <div class="workflow-box mir-workflow-dedup">
          <p>
            <xsl:value-of select="mcri18n:translate('mir.workflow.dedup.found')"/>
          </p>
          <ul>
            <xsl:for-each select="$duplicates">
              <li>
                <a href="{$WebApplicationBaseURL}receive/{@id}">
                  <xsl:value-of select="if (string-length(@title) gt 0) then @title else @id"/>
                </a>
                <small class="text-muted">
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="string-join(for $type in distinct-values(criterion/@type)
                                                    return mirdedup:criterion-label($type), ', ')"/>
                  <xsl:text>)</xsl:text>
                </small>
              </li>
            </xsl:for-each>
          </ul>
          <a class="btn btn-sm btn-primary" href="{$WebApplicationBaseURL}dedup/?id={@ID}&amp;showReturn=true">
            <xsl:value-of select="mcri18n:translate('mir.workflow.dedup.manage')"/>
          </a>
        </div>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- the criterion type translated via dedup.criterion.{type} of MyCoRe, or the type itself -->
  <xsl:function name="mirdedup:criterion-label" as="xs:string">
    <xsl:param name="type" as="xs:string"/>
    <xsl:variable name="key" select="concat('dedup.criterion.', $type)"/>
    <xsl:sequence select="if (mcri18n:exists($key)) then mcri18n:translate($key) else $type"/>
  </xsl:function>

</xsl:stylesheet>
