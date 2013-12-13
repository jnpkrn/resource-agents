<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:int="__internal__"
    xmlns:rha="http://redhat.com/~pkennedy/annotation_namespace/cluster_conf_annot_namespace"
    exclude-result-prefixes="int">

<xsl:output omit-xml-declaration="yes"/>

<xsl:param name="global-init-indent" select="'  '"/>
<xsl:param name="global-indent" select="'  '"/>
<xsl:param name="global-radefine-all" select="'CHILDREN'"/>
<xsl:param name="global-radefine-except"
           select="concat($global-radefine-all, '-EXCEPT-')"/>


<!--
  helper definitions
  -->

<xsl:variable name="SP" select="' '"/>
<xsl:variable name="NL" select="'&#xA;'"/>
<xsl:variable name="NLNL" select="'&#xA;&#xA;'"/>

<!-- NOTES:
     - radefine
       := define[element]
     - restrictingradefine
       := define[element and rha:restriction]
          and in this context also:  ^- and @rha:type = 'forbid-childelem'
          NOTE: element is currently insignificant, as currently
                it is implied by the other constraints
     - forbidchildradefine
       := radefines forbidden to be referred to from restrictingradefines
          (as per particular RAs metadada and in turn intermediate
           rha:restriction annotation)
     - forbidstring
       := for restrictingradefine denotes concatenation of respective
          forbidchildradefines' (ordered!) names (see limitation below
          and also refer to get-forbidstring named template)
     - revmap
       := map using 'key' xslt facility defined reversely, but
          serving for lookups as implied by the particular name
          (i.e., not viceversa, "rev" part is already applied)
     - limitation: currently utmost 4 forbidchildradefines per
                   restrictingradefine, but can be scaled further
                   by brainless extension of concat's if needed
  -->
<xsl:key name="revmap-forbidstring-to-restrictingradefines"
         match="define[rha:restriction[
                    @rha:type = 'forbid-childelem'
                ]]"
         use="concat(
                  rha:restriction[
                      @rha:type = 'forbid-childelem'
                  ][1]/@rha:value,
                  rha:restriction[
                      @rha:type = 'forbid-childelem'
                  ][2]/@rha:value,
                  rha:restriction[
                      @rha:type = 'forbid-childelem'
                  ][3]/@rha:value,
                  rha:restriction[
                      @rha:type = 'forbid-childelem'
                  ][4]/@rha:value
              )"/>

<!-- xsl:key name="revmap-forbidchildradefine-to-restrictingradefines"
         match="define[rha:restriction[
                    @rha:type = 'forbid-childelem'
                ]]"
         use="//define[
                  /element/@name = current()/rha:restriction[
                      @rha:type = 'forbid-childelem'
                  ]@rha:value
              ]"/-->

<xsl:key name="revmap-radefine-to-forbidchildradefines"
         match="define[
                    element/@name
                ]"
         use="//define[rha:restriction[
                  @rha:type = 'forbid-childelem'
                  and
                  @rha:value = current()/element/@name
              ]]"/>

<xsl:variable name="all-radefines"
              select="//define[
                        element/@name
                      ]"/>

<xsl:variable name="all-restrictingradefines"
              select="$all-radefines[rha:restriction[
                          @rha:type = 'forbid-childelem'
                      ]]"/>

<xsl:variable name="all-unique-restrictingradefines"
              select="$all-restrictingradefines[
                          generate-id(
                              key(
                                  'revmap-forbidstring-to-restrictingradefines',
                                  concat(
                                      rha:restriction[
                                          @rha:type = 'forbid-childelem'
                                      ][1]/@rha:value,
                                      rha:restriction[
                                          @rha:type = 'forbid-childelem'
                                      ][2]/@rha:value,
                                      rha:restriction[
                                          @rha:type = 'forbid-childelem'
                                      ][3]/@rha:value,
                                      rha:restriction[
                                          @rha:type = 'forbid-childelem'
                                      ][4]/@rha:value
                                  )
                              )
                          ) = generate-id()
                      ]"/>

<xsl:template name="get-forbidstring">
    <xsl:param name="radefine"/>
    <xsl:value-of select="concat(
                              $radefine/rha:restriction[
                                  @rha:type = 'forbid-childelem'
                              ][1]/@rha:value,
                              $radefine/rha:restriction[
                                  @rha:type = 'forbid-childelem'
                              ][2]/@rha:value,
                              $radefine/rha:restriction[
                                  @rha:type = 'forbid-childelem'
                              ][3]/@rha:value,
                              $radefine/rha:restriction[
                                  @rha:type = 'forbid-childelem'
                              ][4]/@rha:value
                          )"/>
</xsl:template>


<!--
  proceed
  -->

<!-- start with and use identity by default... -->

<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

<!-- ...unless a special case of restrictingradefine, which needs
     $global-radefine-all reference rewritten to custom
     $global-radefine-except$forbidstring... -->

<xsl:template match="@*|node()" mode="rewrite">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="rewrite"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="ref/@name[. = 'CHILDREN']"
              mode="rewrite">
    <!-- NOTE: forbidstring evaluated anew as we do a traversal-based
               template application rather than procedural one
               (as there is generally not a direct link parent-child) -->
    <xsl:variable name="forbidstring">
        <xsl:call-template name="get-forbidstring">
            <xsl:with-param name="radefine"
                            select="ancestor::define[last()]"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:attribute name="{name()}">
        <xsl:value-of select="concat($global-radefine-except,
                                     $forbidstring)"/>
    </xsl:attribute>
</xsl:template>

<!-- ... which is triggered amongst others in the following core logic
     matching any radefine -->

<xsl:template match="define[
                        element/@name
                     ]">
    <xsl:variable name="forbidstring">
        <xsl:call-template name="get-forbidstring">
            <xsl:with-param name="radefine"
                            select="."/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="self" select="."/>

    <!-- identity modulo rha:restriction + rewrite or not as per above -->
    <xsl:copy>
        <xsl:choose>
            <xsl:when test="$forbidstring != ''">
                <xsl:apply-templates select="@*|*[
                                                 name() != 'rha:restriction'
                                             ]|processing-instruction()|comment()"
                                     mode="rewrite"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="@*|*[
                                                 name() != 'rha:restriction'
                                             ]|processing-instruction()|comment()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:copy>

    <!-- if we know that $global-radefine-except$forbidstring is not
         defined by us (set of all radefines is set of all
         restrictingradefines for this very $forbidstring) AND it is
         the first restrictingradefine for particular forbidchildradefines
         (virtually an ordered set, as concatenation keeps ordering),
         define empty $global-radefine-except$forbidstring symbol, just
         for the sake of being defined at all (otherwise it couldn't be
         resolved when no such forbidchildradefine existed) -->
    <xsl:if test="$forbidstring != ''
                  and
                  count(
                      key(
                          'revmap-radefine-to-forbidchildradefines',
                          key(
                              'revmap-forbidstring-to-restrictingradefines',
                              $forbidstring
                          )[1]
                      )
                  ) = count($all-radefines)
                  and
                  generate-id(
                      key(
                          'revmap-forbidstring-to-restrictingradefines',
                          $forbidstring
                      )
                  ) = generate-id()">
        <xsl:value-of select="concat($NL, $global-init-indent)"/>
        <xsl:element name="define">
            <xsl:attribute name="name">
                <xsl:value-of select="concat($global-radefine-except,
                                             $forbidstring)"/>
            </xsl:attribute>
            <xsl:attribute name="combine">
                <xsl:value-of select="'choice'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:if>

    <!-- state the membership of the current radefine in all various
         $global-radefine-except$forbidstring'ish sets by the means of
         "combining definition" feature of Relax NG (similar to what is
         already done with $global-radefine-all themselves) -->
    <xsl:for-each select="$all-unique-restrictingradefines">
        <!-- $forbidstring use here always a bug, but cannot be redefined -->
        <xsl:variable name="forbidstring-other">
            <xsl:call-template name="get-forbidstring">
                <xsl:with-param name="radefine"
                                select="."/>
            </xsl:call-template>
        </xsl:variable>
        <!-- access via the first item below is because this is the only
             guaranteed to exist -->
        <xsl:if test="not(
                          key(
                              'revmap-radefine-to-forbidchildradefines',
                              key(
                                  'revmap-forbidstring-to-restrictingradefines',
                                  $forbidstring-other
                              )[1]
                          )[generate-id() = generate-id($self)]
                      )">
            <xsl:value-of select="concat($NL, $global-init-indent)"/>
            <xsl:element name="define">
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($global-radefine-except,
                                                 $forbidstring-other)"/>
                </xsl:attribute>
                <xsl:attribute name="combine">
                    <xsl:value-of select="'choice'"/>
                </xsl:attribute>
                <xsl:element name="ref">
                    <xsl:attribute name="name">
                            <xsl:value-of select="$self/@name"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:for-each>

</xsl:template>

</xsl:stylesheet>
